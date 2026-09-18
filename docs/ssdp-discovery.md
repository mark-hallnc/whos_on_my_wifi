# SSDP / UPnP discovery

The normal scan retains TCP probing and Android NSD, then runs SSDP. Address
progress continues to represent TCP probes; the additional stage displays
"Looking for smart devices...".

One M-SEARCH request is sent to 239.255.255.250:1900 with HTTP/1.1 framing,
HOST: 239.255.255.250:1900, MAN: "ssdp:discover", MX: 2 and ST: ssdp:all.
Lines and the terminating blank line use CRLF. Listening lasts three seconds;
the entire SSDP stage has a four-second deadline, including XML work. At most
128 unique advertisements, 32 description URLs and three concurrent fetches
are processed. This short window is best effort, not an exhaustive inventory.

The UDP socket binds the captured local IPv4 on an ephemeral port and selects
the outgoing interface with IP_MULTICAST_IF. Multicast TTL is two. M-SEARCH
responses are unicast to that socket, so this implementation does not join a
multicast receive group or acquire another Android MulticastLock. Existing NSD
multicast handling is unchanged. No native Android changes, SDK-level changes
or permissions were needed. Devices requiring unsolicited multicast NOTIFY
monitoring are outside this foreground discovery scope.

Responses are limited to 8 KiB and headers are case-insensitive. Stored headers:
LOCATION, ST, USN, SERVER, CACHE-CONTROL, EXT, BOOTID.UPNP.ORG, CONFIGID.UPNP.ORG.
Malformed responses and duplicate ambiguous headers are ignored. Advertisement
identity uses responder IPv4, USN, ST and LOCATION; each URL is fetched once.

Only HTTP/HTTPS LOCATION URLs with a literal usable IPv4 matching the responder
and the captured subnet are fetched. DNS names, other hosts, credentials,
fragments, loopback, multicast, network/broadcast addresses and invalid ports
are rejected. HTTP sockets bind the captured local IPv4, bypass proxies, retain
normal TLS certificate checks and reject ALL redirects and compressed bodies.
Connection timeout is 600 ms; response-header/body inactivity timeout is 800 ms;
total request deadline is 1800 ms. Responses are capped at 256 KiB, including
chunked bodies. XML DTD/entity declarations are rejected before parsing with
the Dart xml package; nesting, node count and retained field lengths are bounded.
Only UTF-8 XML is supported. Endpoint and manufacturer/model URLs remain inert
technical metadata; no control, event subscription or SCPD requests are made.

Stored device fields: friendlyName, manufacturer, manufacturerURL,
modelDescription, modelName, modelNumber, modelURL, serialNumber, UDN, deviceType,
presentationURL. Service fields: serviceType, serviceId, controlURL, eventSubURL,
SCPDURL. Root device identity is used; embedded devices' services are retained.

Merging uses IPv4 and preserves custom names, current-device/gateway labels,
hostname, earliest firstSeen, stronger existing type/confidence, services, ports
and evidence. UPnP friendlyName is stored separately as discoveredName. New
SSDP-only hosts are included even when description retrieval fails. Only a
successfully parsed local description adds its HTTP port; service endpoints do
not imply additional open ports. Exact standard device types can suggest media
device, printer, router or camera; vague/vendor-specific types remain unknown.
UPnP identity is self-reported and receives at most medium confidence.

The shared scan token handles user cancellation, lifecycle/disposal and network
changes. Network verification runs before merges and every 400 ms. Cancellation
closes UDP and HTTP resources, clears queued work and rejects late results;
completed discoveries remain visible. Fixture-based tests cover parsing,
merging, cancellation, integration, deadlines and HTTP safety without a LAN.

Protocol reference: https://upnp.org/specs/arch/UPnP-arch-DeviceArchitecture-v1.0-20080424.pdf
