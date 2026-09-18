# MAC and vendor enrichment

After TCP, NSD and SSDP complete, NetworkScanner reads NeighborTableService,
rechecks the captured network/permission identity, and enriches existing rows by
IPv4. No rows are created from a cached neighbor table alone, no new probes are
sent, and online status, timestamps, confidence, type and session IDs stay intact.

Android's NeighborTableChannel uses a background executor, with these read-only
sources scoped to the interface owning the captured local IPv4:

1. `/proc/net/arp`: complete Ethernet entries only.
2. `/system/bin/ip -4 neigh show`: no shell interpolation; rows are filtered by
   the active OS interface (unfiltered output retains the `dev` column);
   an 800 ms watchdog destroys the process. Only resolved neighbor states qualify.
3. `NetworkInterface.hardwareAddress`: current device only, if exposed by Android.

Each text source is bounded to 256 KiB; Dart parses at most 2048 rows per source.
Conflicting MACs for an IP are discarded. Interface and local IPv4 are checked
before/after native reads; Dart also validates the subnet and rechecks the full
scan network identity before accepting results. Shared cancellation interrupts
the command, ignores late channel replies and preserves prior discoveries.
The bridge has a 1.5-second deadline. Native work also stops on Activity.onStop
and disposal; executor/watchdog resources are shut down on disposal.

Android 10+ restricts `/proc/net`; SELinux may also deny neighbor netlink access
used by `ip`. Some devices omit the command. Hardware MAC access can be redacted
or absent. Empty results and denied access are normal and never fail the scan.
There is no root, privileged permission, hidden API, IPv6 neighbor discovery,
ARP stimulation, packet capture or neighbor-table mutation.

MACs normalize to uppercase colon-separated EUI-48. Malformed, zero, multicast,
broadcast and Android's `02:00:00:00:00:00` placeholder are rejected. The U/L bit
marks local/private addresses; this indicates local administration, not proof
that the address changes or that the device is suspicious. Such addresses never
receive OUI vendor attribution. Details explain this and still show independently
reported UPnP manufacturers when present.

VendorLookupService loads the bundled IEEE MA-L JSON once, caches a Map and
performs constant-time 24-bit prefix lookup. See assets/data/README.md for source,
snapshot count, hash, scope and update format. Explicit protocol manufacturer
(`reportedManufacturer`) and OUI assignment (`macVendor`) remain separate.
`manufacturer` prefers explicit metadata, then a global MAC's OUI vendor. Both
service mergers preserve this distinction, including UPnP arriving after OUI.
No hardware type or confidence upgrade is inferred from vendor alone.

MAC may become a useful future identity signal across DHCP changes, but must be
reconciled with private addresses, spoofing, shared interfaces and conflicting
observations. This task does not change IDs or add persistence. Existing device
storage remains session-only.

Android restriction reference:
https://developer.android.com/about/versions/10/privacy/changes#proc-net-filesystem
