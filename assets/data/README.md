# Bundled OUI vendor registry

Source: IEEE Registration Authority public MA-L listing:
https://standards-oui.ieee.org/oui/oui.txt
Public listing and registry documentation:
https://standards.ieee.org/products-programs/regauth/

Retrieved 2026-09-17. `oui_vendors.json` contains 40,163 24-bit assignments
(1,385,053 bytes). SHA-256:
`7A3BA55C2B1088EE1D6BBD8D7790CEF763C76F6D562250A4A1BD3AACA77B8A82`.

The compact UTF-8 JSON maps six uppercase hex digits to the registered
organization name. It was generated from the public listing's `(base 16)` rows,
retaining organization names and omitting postal addresses. This is public
registry assignment data, not a proprietary vendor database; IEEE is the source
of the registrations. No IEEE standards document or third-party lookup code is
bundled. Organization names do not establish product model or device category.

This snapshot supports MA-L only. Delegated `IEEE Registration Authority` blocks
and `Private` entries deliberately produce no vendor, since MA-M/MA-S sub-block
registrations are not bundled. Local/unicast-bit checks happen before lookup.

To update later, replace this JSON with the same schema from a reviewed public
registry snapshot, update attribution/count/hash here and the asset integrity
test. Scanner logic stays unchanged. The application never downloads updates or
sends MAC addresses to a vendor lookup service.
