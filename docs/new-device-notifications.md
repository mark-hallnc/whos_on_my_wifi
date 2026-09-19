# New devices and local notifications

The existing Drift reconciliation transaction is the source of truth. No second
history database or permanent `isNew` column is used. `ScanResult.reconciliation`
reports inserted, matched/updated, newly offline, and eligible new device IDs.
Matched rows are discovery updates, not field-by-field change detection.

Eligible new IDs are rows inserted by the current successful scan, excluding the
current phone. Existing MAC/UPnP/service identity matching, conservative fallback
upgrades, and private-MAC rules are unchanged. Ambiguous identity still has the
limitations of the existing identity service; IP-only sightings are not permanent
identity. Partial scans can save discoveries but never report eligible new IDs.

The first successful scan establishes a baseline and suppresses both NEW badges
and notifications. `saved_networks.last_scanned` identifies an established baseline,
including existing installations and networks whose old scan-history rows were
pruned. Cancelled/failed scans do not establish it. No schema migration is needed.

NEW badges use repository session metadata for the latest successful scan. They
clear on a later scan, network/presence reset, or restart. Notifications and the
in-app summary consume the reconciliation outcome only after the transaction has
committed. Re-saving the same scan returns a duplicate outcome with no alert IDs;
the delivery service also guards repeated/concurrent calls for the same scan.
Subsequent scans match the stored identities, so IP/name/metadata changes alone do
not alert again when an identity can be reconciled.

`NewDeviceNotificationService` separates delivery from detection. Android uses
`flutter_local_notifications` 22.3.1 and channel `new_devices` / `New devices`, with
default importance/priority, ordinary defaults, and a monochrome status icon.
One scan creates at most one notification; multiple devices produce a summary.
One notification slot is reused so scans do not accumulate an alert stack. Tapping
opens the existing Devices tab, without starting a scan or adding deep links.

The local SharedPreferences preference defaults on. Initialization never requests
permission. Android 13+ permission is requested only by explicitly enabling the
setting or pressing Allow notifications in Settings. Denial/revocation/channel
blocking is reflected in Settings; scans never prompt or retry alerts later.
In-app badges and summaries work regardless of OS permission or delivery failure.
Initialization and delivery failures are nonfatal. Notifications occur only for
scans already performed by the app; no background jobs, alarms, boot receivers,
cloud messaging, accounts, or remote settings are added.

Android build configuration follows the package's Java 17/core-library desugaring
requirements. Only POST_NOTIFICATIONS is added to the manifest; existing network
permissions and discovery code are unchanged.
