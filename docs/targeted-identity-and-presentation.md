# Live presentation and targeted identity enrichment

## Presentation, not identity merging

`ScanHistoryOverlay.present` is the single Home presentation normalization step.
It selects one card per IPv4 address; an online row takes precedence over offline
history. During reconciliation overlay, freshly observed IPs explicitly suppress
historical cards at those IPs. Safe identity matches retain custom metadata; an
IP collision alone never copies a different device's custom name/classification.
Historical identities and IP histories remain in SQLite and Saved Networks.

A saved current-phone row is presented online at Android's current local IP only
while the saved-network key matches the attached network. Other saved devices
remain offline until observed, or retain their existing session presence during
unfinished/failed/cancelled scans. A successful scan establishes absence. Summary
counts, filtering, DeviceCard and navigation to details all use the normalized
snapshot. The current list's known count is the number of presented records;
Saved Networks retains the complete historical record count, including IP reuse.

## Targeted protocol budgets

- NBNS: unicast wildcard Node Status (NBSTAT) query to UDP 137, 400 ms. Target only
  confirmed-live SMB/workstation/computer candidates, not every subnet address.
  Names require active, non-conflicting unique name records; workgroup comes from
  a group record. A validated six-byte unit ID is retained as reported MAC evidence
  only if no MAC is already known. No manufacturer is guessed from workgroup/name.
- LLMNR: multicast PTR query to 224.0.0.252:5355, 400 ms, at most 12 unnamed,
  already-live targets. Only that target IP/5355 with the correct transaction,
  question and answer owner can enrich the device. No system reverse DNS.
  RFC 4795 forbids unicast UDP queries; its section 2.4 permits multicast PTR when
  ICMP cannot be processed, as in this Dart sender. Hosts may disable or decline
  these queries. A timeout means no additional name, never absence of the device.
- NBNS/LLMNR share a one-second enrichment window and at most 16 selected targets,
  prioritized for SMB evidence. Eight target workers, up to two queries each,
  bound the concurrent UDP sockets to 16. No retries or subnet-wide query loops.
- WS-Discovery: one unfiltered Probe to 239.255.255.250:3702, two-second window,
  overlapping TCP/NSD/SSDP. Uses the April 2005 WS-Discovery/WS-Addressing profile
  supported by Windows WSDAPI and ONVIF devices. 2009-only responders may be missed.
  ProbeMatches are correlated by MessageID/RelatesTo, validated SOAP/action
  namespaces, and local source IP. Up to 64 unique endpoint observations are
  published incrementally after network verification, including WS-only hosts.
- WS XML is capped at 32 KiB, 2,048 events, depth 24 and 16 matches per packet.
  DTD/entity declarations are rejected. DNS-style packet parsers cap at 4 KiB,
  bound record counts and name length, and reject compression cycles/truncation.
- XAddrs must be HTTP(S), literal local IPv4 and belong to the responding host.
  Public URLs, DNS names, credentials and other-host URLs are rejected. No XAddr
  is fetched, so no HTTP redirects, metadata execution or control requests occur.

All datagrams bind to the captured local address. Multicast sends select that
interface explicitly; responses are unicast, so no additional MulticastLock is
needed. Cancellation closes sockets, cancels subscriptions/timers, discards late
binds/replies and stops target scheduling. Already-published metadata survives.
Network verification uses the scanner's existing periodic/coalesced mechanism.
Unsupported desktop previews send none of these new probes by default; tests
inject a fake transport and enable them explicitly. No native changes are needed.

## Evidence and storage

Existing `DiscoveredService` fields hold protocol, hostname, workgroup, reported
MAC, endpoint reference, expanded QName types, scopes and safe XAddrs. Existing
service persistence carries those fields; no schema migration is needed. Valid
WS endpoint UUIDs are an additional network-scoped persistent identity alias.
The MAC, UPnP and other existing identity/conflict rules remain in effect.

Central identification derives Computer/Medium from a useful NBNS name plus SMB
success/advertisement evidence; a refused SMB port alone does not count as SMB.
Recognized namespace-qualified WS printer and camera types give Medium confidence.
Generic web-service/Windows types remain ambiguous. LLMNR is name evidence, not
hardware evidence. Existing stronger identity and all user-owned fields survive.
No manufacturer or model is inferred from an endpoint URL or a generic service.

## UI

Device Details now has compact Identification, Network and History sections.
Empty services, ports, previous-IP rows and missing metadata are hidden. Raw
identifiers, protocol fields, evidence and raw hostnames are behind a collapsed
Technical details tile. One Edit action edits name/classification/notes; empty
notes get a compact Add note action when editable.

Home keeps the existing layout and ad placement, combines local IP/subnet and
online/known counts, moves gateway to Network details, and hides normal completed
probe counts. Cards retain subtle Online/Offline status and NEW; Unknown
classification is hidden. Warnings and cancellation feedback remain visible.

## References

- RFC 1002 NBSTAT: https://www.rfc-editor.org/rfc/rfc1002
- RFC 4795, especially sections 2.3/2.4: https://www.rfc-editor.org/rfc/rfc4795
- Windows WSDAPI ProbeMatches: https://learn.microsoft.com/en-us/windows/win32/wsdapi/probematches-message
- ONVIF device discovery: https://www.onvif.org/wp-content/uploads/2016/12/ONVIF_Base_Test_Specification_16.07.pdf

Validation uses fixture packets/XML, mocked exchanges, an in-memory Drift DB and
widget tests. No physical LAN discovery-rate measurements are claimed.

## Files changed

Created:

- lib/services/dns_wire.dart
- lib/services/identity_datagrams.dart
- lib/services/nbns_discovery_service.dart
- lib/services/llmnr_resolver.dart
- lib/services/ws_discovery_service.dart
- lib/services/local_identity_discovery.dart
- test/identity_protocols_test.dart
- test/live_presentation_test.dart
- docs/targeted-identity-and-presentation.md

Updated:

- lib/models/discovered_service.dart
- lib/models/network_device.dart
- lib/services/network_scanner.dart
- lib/services/scan_history_overlay.dart
- lib/services/device_identification_service.dart
- lib/services/device_identity_service.dart
- lib/screens/home_screen.dart
- lib/screens/device_details_screen.dart
- lib/widgets/current_network_card.dart
- lib/widgets/device_card.dart
- test/network_flow_test.dart
- test/widget_test.dart

The database schema, Android native code, permissions, dependencies and advertising
widget/placement are unchanged.

## Validation

- flutter analyze: no issues found.
- flutter test: 215 tests passed.
- Android debug build not run: no native/configuration/dependency changes.
