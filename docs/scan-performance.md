# Foreground scan performance

TCP reachability, Android NSD and SSDP run concurrently after network validation.
The existing scan lock remains held until all workers and discovery sessions stop.
Neighbor/MAC enrichment runs once afterward, followed by centralized identification
and final network validation. Persistence follows through the existing repository.
No reverse DNS, background scans, new protocols or broad port sweep are added.

## Budgets

- At most 1,024 remote candidate addresses; lazy subnet iterator, excluding this
  phone and network/broadcast addresses where applicable.
- TCP workers: <=256 candidates: 48; 257–512: 40; 513–1,024: 32.
  Each worker opens only one socket at a time. UPnP has its separate cap of three
  HTTP fetches, so application socket load stays bounded (up to 51 TCP sockets).
- Tier 1: 80, 443, 22, 445, each 250 ms. If every attempt lacks evidence,
  tier 2 tries only 631 (IPP) and 8009 (Cast), each 150 ms. Both are useful
  endpoints that can be present while the original four ports are filtered.
- Stop immediately on success or explicit OS connection refusal. No generic
  SocketException, timeout, reset, no-route or unreachable error proves presence.
  ECONNREFUSED is Android/Linux 111, Apple 61, Windows 10061. Android reference:
  https://android.googlesource.com/platform/bionic/+/ac62e8285630592b1bf060711fa13e654c36db20/libc/private/bionic_errdefs.h
  A network middlebox can itself reject a connection; this is reachability evidence,
  not authenticated device identity. Refused ports are not recorded as open.
- NSD retains its 4-second native window (4.5-second Dart fallback), rather than
  shortening coverage of eleven service families across four bounded browsers.
- SSDP listens 3 seconds, with a 4-second overall stage ceiling. Existing UPnP
  budgets remain 600 ms connection, 800 ms read, 1,800 ms total and 256 KiB XML.
  Advertisements are deduplicated; each LOCATION is fetched and merged once.
- OS network verification is coalesced and cached for 400 ms, with forced checks
  at phase boundaries and a 2-second access deadline. Cancellation releases
  waiters immediately; late platform results cannot mutate the finished scan.
  Changes are detected at the next verification, not instantaneously.
- UI snapshots publish at most every 150 ms during a phase. Phase/terminal changes
  flush immediately, including cancellation, and dispose the trailing timer.
- A service-proven address skips pending reachability work; a running probe stops
  its remaining ports once service evidence exists. TCP arriving later preserves
  service identity, ports, firstSeen and other metadata.
- TCP cancellation waits at most the current 250 ms attempt, not remaining ports
  or candidates. NSD listeners, SSDP sockets and pending HTTP fetches are stopped.

## Metrics and interpretation

ScanResult carries a phase and immutable session diagnostics, preserved through
history overlay and repository reconciliation (not written into database history).
Network Information exposes a collapsed diagnostics section. Durations overlap;
adding TCP/NSD/SSDP durations does not yield total time. Total is scanner time,
excluding persistence. Identified count means medium/high identification confidence.
NSD-only and SSDP-only counts exclude TCP and the other service source; the combined
service-only count includes devices shared by NSD and SSDP. Metadata-only phone and
router rows are not TCP live hosts. Skipped probes count addresses skipped before
starting a TCP attempt. Checked addresses include such already-confirmed addresses.
The home summary separates online devices from all known devices in history.

Possible isolation is only a hypothesis: >=16 candidates, every candidate checked,
a responding gateway, no peers beyond phone/gateway, and both service sources
finished without warnings. A quiet LAN with only one client can also meet it.
The UI says communication *may* be restricted, never that isolation is proven.

## Existing performance safeguards retained

OUI data is loaded once through a cached Future, parsed with compute off the UI
isolate and looked up by Map. It is not reparsed per scan. Saved Networks and
Settings are now mounted on first visit, so their queries do not delay Home.
Notification initialization remains asynchronous. XML size/depth/node and NSD
service limits bound processing; no new isolate is needed for small per-device merges.

Completed-scan reconciliation already uses one Drift transaction, on the background
SQLite executor. Existing indexes cover network devices, network identity aliases,
device services, device IP history, and network scan retention/order. No SQL query
requires a new MAC/current-IP index: reconciliation resolves preloaded identities.
No schema change, generated-code update or migration is needed. Existing rollback
and reconciliation tests protect transaction behavior.

NSD retains its scoped legacy MulticastLock; modern Android NSD manages reception.
SSDP sends multicast but receives unicast replies on the active interface's bound
socket, so it does not acquire a competing multicast reception lock. Native code
and its bounded callback processing are unchanged.

## Targets, not benchmark claims

Typical /24 goal: first evidence within about one second, completion around 3–8
seconds, responsive scrolling, cancellation within the active attempt's deadline.
A fully filtered /24 can require six worker waves x 1.3 seconds = about 7.8 seconds
of TCP budget, plus OS/MAC overhead. Slow Android calls, scheduling and filtered
networks can exceed the goal. No physical-LAN benchmark was performed here.
Use the diagnostics on representative Android devices for subsequent tuning.
