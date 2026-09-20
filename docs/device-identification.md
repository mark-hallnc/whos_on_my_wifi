# Device identification

`DeviceIdentificationService.identify` is a pure Dart assessment of already
collected metadata. Discovery mergers delegate to it; the scanner runs it again
after MAC/OUI enrichment. Persistence uses the same service after matching a
stored identity, combining saved evidence with the current observation. Loading
saved devices also applies current presentation rules. No new requests, probes,
protocols, permissions, Android code, dependencies or database tables are added.

## Field precedence and preservation

- User custom name, classification and notes remain user-owned. Current-device
  and gateway display labels retain their existing precedence over custom names.
- Discovered name: useful UPnP friendly name, Cast friendly-name TXT, meaningful
  service instance, existing discovered identity, then normalized hostname.
  Generic HTTP instance names have less weight than dedicated device services.
- Manufacturer: UPnP-reported manufacturer, printer manufacturer TXT, existing
  explicit metadata, then MAC OUI fallback. OUI is never copied into the reported
  manufacturer field, and private/local MACs never supply vendor identification.
- Model fields: UPnP, protocol-specific TXT, then existing model fields. Conflicting
  printer TXT model data is excluded when UPnP reports a different manufacturer.
  A changed direct manufacturer does not inherit the prior vendor's model.
- Small internal field-quality values preserve stronger prior names, models,
  explicit manufacturers and types when later scans are weaker. They are not UI
  scores. Existing high-confidence classified legacy records are conservatively
  retained where no newer contradictory manufacturer evidence exists.
- Quality and short conflict notes use optional keys in the existing bounded
  `details_json`. Old rows remain readable; schema version/generation is unchanged.
  Persistence still writes scanner metadata separately from user-editable columns.
- Current source fields win equal-quality ties. Service candidates are sorted by
  identity, avoiding dependence on discovery arrival order for distinct services.

Raw hostnames, OUI strings, reported manufacturers and protocol attributes remain
available in technical details. Display cleanup removes trailing dots/`.local`,
excess whitespace, generic names, protocol artifacts, IP/numeric-only names and
UUID-only names. Legitimate capitalization and punctuation remain. Exact aliases
normalize a small set of Samsung, Google, Espressif, Apple, HP and Roku names;
distinct companies such as Hewlett Packard Enterprise are not collapsed into HP.

## Types and confidence

IPP/IPPS/printer services suggest printer; workstation suggests computer without
claiming Windows. Recognized UPnP device schemas suggest router, printer, media or
camera. Cast suggests media capability. AirPlay/RAOP needs vendor/model support
before assigning media type. Explicit television model wording plus media evidence
can suggest television; Chromecast, Roku and Apple TV endpoints are not themselves
assumed to be televisions. Clear camera/thermostat model text is used conservatively.
Espressif alone is only a weak IoT hint. Broad vendors never imply phone versus TV.
No DeviceType enum expansion was necessary.

- Low: TCP/IP, OUI alone, weak hostname or generic services alone.
- Medium: one meaningful protocol clue, advertised model, hostname plus vendor,
  or gateway role alone.
- High: explicit UPnP name/type with manufacturer/model; printer service with
  vendor/model and hostname/model support; gateway role plus UPnP gateway; or
  independent mDNS/UPnP name/model or OUI/UPnP manufacturer agreement with richer
  identity evidence. Repeated advertisements from one source do not raise confidence.

Confidence expresses evidence for identification, not device safety or security.

## Service presentation

Friendly labels include Web Interface, Secure Web Interface, Google Cast, AirPlay,
AirPlay Audio, Printer, Secure Printer, Workstation, File Sharing, Device Information,
Media Playback, Media Controls, Media Library and Internet Gateway. Raw types,
instance names, endpoints and TXT fields remain accessible. Cards show name, useful
manufacturer/model/type information, then IP, omitting empty placeholder text.

TXT decoding is scoped to the relevant protocols. Printer `usb_MFG`, `usb_MDL`
and `ty` semantics follow [Apple's Bonjour Printing specification](https://devimages.apple.com/opensource/BonjourPrinting.pdf).
Cast `fn`/`md` follow [Chromium's Cast discovery implementation](https://raw.githubusercontent.com/chromium/chromium/main/chrome/browser/media/router/discovery/mdns/media_sink_util.cc).
No manufacturer or model is inferred merely from a protocol's brand.
