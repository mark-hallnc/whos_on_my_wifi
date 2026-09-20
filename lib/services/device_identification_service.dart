import '../models/discovered_service.dart';
import '../models/network_device.dart';
import '../models/upnp_description.dart';
import '../utils/identity_text.dart';

typedef _Text = ({String? value, int quality});

/// Pure, deterministic identification from collected evidence. Never does I/O.
/// Direct UPnP > protocol-specific TXT > service instance > hostname > OUI.
/// User edits, persistent IDs, presence and timestamps are not inferred here.
class DeviceIdentificationService {
  static const _printerTypes = {'_ipp._tcp.', '_ipps._tcp.', '_printer._tcp.'};

  static String serviceType(String type) => type
      .toLowerCase()
      .replaceFirst(RegExp(r'\.local\.?$'), '')
      .replaceFirst(RegExp(r'\.+$'), '');
  static bool _is(DiscoveredService s, String type) =>
      serviceType(s.type) == serviceType(type);
  static bool _printer(DiscoveredService s) =>
      _printerTypes.any((t) => _is(s, t));

  static DeviceType upnpType(String? urn) {
    final parts = urn?.toLowerCase().split(':');
    if (parts == null ||
        parts.length != 5 ||
        parts[0] != 'urn' ||
        parts[1] != 'schemas-upnp-org' ||
        parts[2] != 'device' ||
        int.tryParse(parts[4]) == null) {
      return DeviceType.unknown;
    }
    return switch (parts[3]) {
      'mediarenderer' || 'mediaserver' => DeviceType.mediaDevice,
      'internetgatewaydevice' => DeviceType.router,
      'printer' || 'printerdevice' => DeviceType.printer,
      'digitalsecuritycamera' ||
      'digitalsecuritycamerastillimage' ||
      'digitalsecuritycameramotionimage' => DeviceType.camera,
      _ => DeviceType.unknown,
    };
  }

  static _Text _name(String? value, int quality) =>
      (value: IdentityText.name(value), quality: quality);
  static _Text _model(String? value, int quality) =>
      (value: IdentityText.model(value), quality: quality);
  static _Text _field(String? value, int quality) {
    final clean = IdentityText.clean(value);
    return (
      value:
          clean == null ||
              const {
                'unknown',
                'n/a',
                'none',
                'null',
              }.contains(clean.toLowerCase())
          ? null
          : clean,
      quality: quality,
    );
  }

  static _Text _pick(Iterable<_Text> values) {
    _Text best = (value: null, quality: 0);
    for (final candidate in values) {
      if (candidate.value != null && candidate.quality > best.quality) {
        best = candidate;
      }
    }
    return best;
  }

  static int _quality(NetworkDevice? d, String field, int legacy) =>
      d?.identificationQuality[field] ?? legacy;
  static bool _same(String? a, String? b) =>
      a != null && b != null && a.toLowerCase() == b.toLowerCase();

  static NetworkDevice identify(NetworkDevice d, {NetworkDevice? previous}) {
    final servicesById = <String, DiscoveredService>{
      for (final s in previous?.services ?? <DiscoveredService>[])
        s.identity: s,
      for (final s in d.services) s.identity: s,
    };
    final services = servicesById.values.toList()
      ..sort((a, b) => a.identity.compareTo(b.identity));
    final freshFields = d.upnpDescription?.fields ?? <String, String>{};
    final oldFields = previous?.upnpDescription?.fields ?? <String, String>{};
    final changedUpnpVendor =
        IdentityText.manufacturer(freshFields['manufacturer']) != null &&
        IdentityText.manufacturer(oldFields['manufacturer']) != null &&
        !_same(
          IdentityText.manufacturer(freshFields['manufacturer']),
          IdentityText.manufacturer(oldFields['manufacturer']),
        );
    final fields = <String, String>{
      for (final e in oldFields.entries)
        if (!changedUpnpVendor || !e.key.startsWith('model')) e.key: e.value,
      ...freshFields,
    };
    final upnp = fields.isEmpty
        ? null
        : UpnpDescription(
            fields,
            d.upnpDescription?.services ??
                previous?.upnpDescription?.services ??
                [],
          );
    final notes = <String>{};
    final serviceNames = <_Text>[];
    final serviceModels = <_Text>[];
    final serviceVendors = <_Text>[];
    final hostnames = <String>[];
    final upnpVendor = IdentityText.manufacturer(upnp?.manufacturer);
    for (final s in services) {
      if (!s.type.startsWith('_')) {
        continue; // UPnP action names aren't device names.
      }
      final attrs = {
        for (final e in s.attributes.entries) e.key.toLowerCase(): e.value,
      };
      final vendor = _printer(s) ? attrs['usb_mfg'] : null;
      if (IdentityText.manufacturer(vendor) != null) {
        serviceVendors.add((value: vendor, quality: 80));
      }
      final conflict =
          upnpVendor != null &&
          IdentityText.manufacturer(vendor) != null &&
          !_same(upnpVendor, IdentityText.manufacturer(vendor));
      if (conflict) {
        notes.add(
          'UPnP manufacturer takes precedence over conflicting printer TXT manufacturer.',
        );
      }
      String? model;
      if (_printer(s)) model = attrs['usb_mdl'] ?? attrs['ty'];
      if (_is(s, '_googlecast._tcp.')) {
        model = attrs['md'];
        serviceNames.add(_name(attrs['fn'], 85));
      }
      if (_is(s, '_airplay._tcp.') ||
          _is(s, '_raop._tcp.') ||
          _is(s, '_device-info._tcp.')) {
        model = attrs['model'];
      }
      if (!conflict) serviceModels.add(_model(model, 80));
      var instance = s.name;
      if (_is(s, '_raop._tcp.')) {
        instance = instance.replaceFirst(
          RegExp(r'^[0-9a-f]{12}@', caseSensitive: false),
          '',
        );
      }
      serviceNames.add(
        _name(
          instance,
          _is(s, '_http._tcp.') || _is(s, '_https._tcp.') ? 45 : 70,
        ),
      );
      if (IdentityText.name(s.hostname) != null) hostnames.add(s.hostname!);
    }
    final hostname = IdentityText.name(d.hostname) != null
        ? d.hostname
        : hostnames.firstOrNull ?? previous?.hostname;
    final chosenName = _pick([
      _name(upnp?.friendlyName, 90),
      ...serviceNames,
      _name(d.discoveredName, _quality(d, 'name', 50)),
      _name(previous?.discoveredName, _quality(previous, 'name', 50)),
      _name(hostname, 30),
    ]);
    final chosenVendor = _pick([
      (value: upnpVendor == null ? null : upnp?.manufacturer, quality: 90),
      ...serviceVendors,
      (
        value: IdentityText.manufacturer(d.reportedManufacturer) == null
            ? null
            : d.reportedManufacturer,
        quality: _quality(d, 'manufacturer', 70),
      ),
      (
        value: IdentityText.manufacturer(previous?.reportedManufacturer) == null
            ? null
            : previous?.reportedManufacturer,
        quality: _quality(previous, 'manufacturer', 70),
      ),
    ]);
    final mac = d.macAddress ?? previous?.macAddress;
    // withMac already drops private OUI values; the model also guards this path.
    final privateMac = d.macAddress == null
        ? previous?.isPrivateMac ?? false
        : d.isPrivateMac;
    final macVendor = privateMac
        ? null
        : (d.macAddress == null
              ? d.macVendor ?? previous?.macVendor
              : d.macVendor);
    final vendor =
        IdentityText.manufacturer(chosenVendor.value) ??
        IdentityText.manufacturer(macVendor);
    final oldVendor = previous?.manufacturer;
    final vendorChanged =
        oldVendor != null &&
        vendor != null &&
        !_same(oldVendor, vendor) &&
        chosenVendor.quality >= _quality(previous, 'manufacturer', 70);
    final model = _pick([
      _model(upnp?.modelName, 90),
      ...serviceModels,
      _model(d.modelName, _quality(d, 'model', 60)),
      if (!vendorChanged)
        _model(previous?.modelName, _quality(previous, 'model', 60)),
    ]);
    final modelNumber = _pick([
      _field(upnp?.modelNumber, 90),
      _field(d.modelNumber, _quality(d, 'modelNumber', 60)),
      if (!vendorChanged)
        _field(previous?.modelNumber, _quality(previous, 'modelNumber', 60)),
    ]);
    final modelDescription = _pick([
      _field(upnp?.modelDescription, 90),
      _field(d.modelDescription, _quality(d, 'modelDescription', 60)),
      if (!vendorChanged)
        _field(
          previous?.modelDescription,
          _quality(previous, 'modelDescription', 60),
        ),
    ]);
    if (vendor != null &&
        IdentityText.manufacturer(macVendor) != null &&
        !_same(vendor, IdentityText.manufacturer(macVendor))) {
      notes.add(
        'Device-reported manufacturer takes precedence over a different MAC vendor.',
      );
    }

    var type = DeviceType.unknown;
    var typeQuality = 0;
    void hint(DeviceType value, int quality) {
      if (value != DeviceType.unknown && quality > typeQuality) {
        type = value;
        typeQuality = quality;
      }
    }

    final upnpHint = upnpType(upnp?.deviceType);
    final printer = services.any(_printer);
    final cast = services.any((s) => _is(s, '_googlecast._tcp.'));
    final airplay = services.any(
      (s) => _is(s, '_airplay._tcp.') || _is(s, '_raop._tcp.'),
    );
    final workstation = services.any((s) => _is(s, '_workstation._tcp.'));
    hint(upnpHint, 90);
    if (printer) hint(DeviceType.printer, 80);
    if (workstation) hint(DeviceType.computer, 60);
    // Services imply capabilities. Never equate Cast with TV or Apple with phone.
    if (cast || (airplay && (vendor != null || model.value != null))) {
      hint(DeviceType.mediaDevice, 60);
    }
    if (vendor == 'Espressif') hint(DeviceType.iot, 20);
    // A model is stronger than a room/instance name. Chromecast/Apple TV are
    // media endpoints, not evidence that the endpoint itself is a television.
    if ((cast || upnpHint == DeviceType.mediaDevice) &&
        model.value != null &&
        RegExp(
          r'\b(?:television|smart tv|oled tv|qled tv)\b',
          caseSensitive: false,
        ).hasMatch(model.value!) &&
        !RegExp(
          r'chromecast|apple tv|roku',
          caseSensitive: false,
        ).hasMatch(model.value!)) {
      hint(DeviceType.television, 95);
    }
    if (model.value != null &&
        RegExp(
          r'\b(?:ip camera|security camera|network camera)\b',
          caseSensitive: false,
        ).hasMatch(model.value!)) {
      hint(DeviceType.camera, 90);
    }
    if (model.quality >= 80 && model.value != null &&
        RegExp(r'\bthermostat\b', caseSensitive: false).hasMatch(model.value!)) {
      hint(DeviceType.thermostat, 90);
    }
    for (final old in [d, ?previous]) {
      final quality =
          old.identificationQuality['type'] ??
          (old.confidence == IdentificationConfidence.high ? 95 : 50);
      if (quality >= 75 && !vendorChanged) hint(old.type, quality);
    }
    if (d.isGateway) {
      type = DeviceType.router;
      typeQuality = 100;
    }
    if (d.isCurrentDevice) {
      type = DeviceType.phone;
      typeQuality = 100;
    }

    var confidence = IdentificationConfidence.low;
    final meaningfulService = printer || cast || airplay || workstation;
    final normalizedHost = IdentityText.name(hostname);
    if (upnpHint != DeviceType.unknown ||
        meaningfulService ||
        (model.value != null && model.quality >= 80) ||
        (normalizedHost != null && vendor != null) ||
        (upnpVendor != null &&
            (model.value != null || chosenName.value != null)) ||
        d.isGateway) {
      confidence = IdentificationConfidence.medium;
    }
    final explicitUpnp =
        IdentityText.name(upnp?.friendlyName) != null &&
        upnpHint != DeviceType.unknown &&
        (upnpVendor != null || IdentityText.model(upnp?.modelName) != null);
    final printerIdentity =
        printer &&
        (vendor != null || model.value != null) &&
        (normalizedHost != null || model.value != null);
    final nameAgreement =
        IdentityText.name(upnp?.friendlyName) != null &&
        serviceNames.any(
          (n) => _same(n.value, IdentityText.name(upnp?.friendlyName)),
        );
    final vendorAgreement =
        upnpVendor != null &&
        _same(upnpVendor, IdentityText.manufacturer(macVendor));
    if (explicitUpnp ||
        printerIdentity ||
        (d.isGateway && upnpHint == DeviceType.router) ||
        (nameAgreement &&
            (upnpHint != DeviceType.unknown || model.value != null)) ||
        (vendorAgreement &&
            (model.value != null || upnpHint != DeviceType.unknown))) {
      confidence = IdentificationConfidence.high;
    }
    // Legacy rich records remain useful when a later scan has little evidence.
    for (final old in [d, ?previous]) {
      if (!vendorChanged &&
          old.type != DeviceType.unknown &&
          (old.identificationQuality['type'] ?? 95) >= 75 &&
          old.confidence.index > confidence.index) {
        confidence = old.confidence;
      }
    }
    return NetworkDevice(
      id: d.id,
      ipAddress: d.ipAddress,
      firstSeen: d.firstSeen,
      lastSeen: d.lastSeen,
      customName: previous?.customName ?? d.customName,
      classification: previous?.classification ?? d.classification,
      notes: previous?.notes ?? d.notes,
      hostname: hostname,
      discoveredName: chosenName.value,
      manufacturer: chosenVendor.value,
      macVendor: macVendor,
      macAddress: mac,
      macSource: d.macSource ?? previous?.macSource,
      modelName: model.value,
      modelNumber: modelNumber.value,
      modelDescription: modelDescription.value,
      type: type,
      confidence: confidence,
      isOnline: d.isOnline,
      isCurrentDevice: d.isCurrentDevice,
      isGateway: d.isGateway,
      isNew: d.isNew,
      services: services,
      upnpDescription: upnp,
      ssdpAdvertisements: d.ssdpAdvertisements.isEmpty
          ? previous?.ssdpAdvertisements ?? []
          : d.ssdpAdvertisements,
      discoveryEvidence: {
        ...d.discoveryEvidence,
        ...?previous?.discoveryEvidence,
      }.take(32).toList(),
      openPorts: {...?previous?.openPorts, ...d.openPorts}.toList()..sort(),
      previousIpAddresses: d.previousIpAddresses,
      identificationQuality: {
        'name': chosenName.quality,
        'manufacturer': chosenVendor.quality,
        'model': model.quality,
        'modelNumber': modelNumber.quality,
        'modelDescription': modelDescription.quality,
        'type': typeQuality,
      },
      identificationNotes: notes.toList(),
    );
  }
}
