# Changelog

Notable changes to Trip Planner. Builds are published as Android pre-releases on [GitHub Releases](https://github.com/bullyee/trip_planner/releases). Versions follow [Semantic Versioning](https://semver.org); before 1.0, minor versions may change behavior.

## [0.1.2] - 2026-10-29

### Fixed
- **Import from Bangumi works again** ([#57](https://github.com/bullyee/trip_planner/issues/57)). Two things had broken it:
  - The app requested paths outside Anitabi's documented open API (a connection "pre-warm" of `/` and a title lookup at `/bangumi/{id}`). Anitabi's Cloudflare front blocks any network that does that for a while, so every import then failed with "Couldn't reach Anitabi".
  - Anitabi's open API stopped returning spot coordinates and lists only part of each anime's spots, so even an unblocked import produced nothing.

  Imports now read Anitabi's static map data — the same files its website and iOS app draw the map from — which has every spot with coordinates (214 spots for K-On!, where the open API returned 51 without coordinates). The open API is no longer used.

### Changed
- The map index (~2 MB) is downloaded at most once a day and kept on the device; spot details are re-downloaded only when Anitabi publishes new data. If one Anitabi host is down, the app tries its mirrors.
- Cover images that Anitabi's image host refuses are fetched from its mirror.
- When Anitabi refuses requests (HTTP 403/429), the import stops at once and says the block is temporary, instead of retrying and blaming your connection.
- Imported places are named in their original language (usually Japanese, as on the signs on site); the Chinese translation is used only when there is no original name. Places imported earlier keep their names.
- Spots that Anitabi lists without map coordinates are skipped and counted in the import message. If no spot has coordinates, nothing is imported and the app says so, instead of reporting "Imported 0 POIs" and opening an empty list.
- The Compose cutout downloads its AI model (~176 MB) the first time you tap **Download AI model**, instead of expecting it inside the app package ([#56](https://github.com/bullyee/trip_planner/pull/56)). The APK size is unchanged (~93 MB).
- The app's version number now matches the release (0.1.2, build 3). Earlier builds all reported 1.0.0.

### Known issues
- The static map data isn't part of Anitabi's documented API. Its address already changed once (Aug 2026); if it moves again, importing fails until an app update follows it.
- If your network was blocked by an older build, cover images may be missing until Anitabi lifts the block and its mirror also refuses; switching networks (Wi-Fi ↔ mobile data) works around it.

### Developer
- Claude Code project skills: `.claude/skills/run-app` (run and drive the app on the Android emulator) and `.claude/skills/release` (this release process).
- `THIRD_PARTY_NOTICES.md` credits MiriaGo (MIT), whose handling of Anitabi's map data the import follows, and the Anitabi data license.

## [0.1.1] - 2026-06-11

### Added
- **Trip Calendar scheduling**: drag POIs into a day with auto-cascading start/end times, per-stop duration, travel time between stops, fixed-time locking, and "free time" gaps; drag to reorder stops.
- **Cloud sync (experimental)**: back up and share a trip across devices via Firestore (sign-in required).
- **Batch region assignment**: add many POIs to a region at once.

### Removed
- The placeholder Tickets organizer and manual JSON export/import (superseded by cloud sync).

### Changed
- The README is now an end-user guide.

### Known issues
- Cloud sync only uploads/backs up so far; two-way pull is still in progress.
- The Anime Camera background cutout runs on arm64 devices only.

## [0.1.0] - 2026-06-06

First Android demo build.

### Added
- Regions (ROI) and places (POI), calendar scheduling, organization by anime and tag.
- Import spots from Anitabi via Bangumi search.
- Anime cutout (ISNet ONNX / ML Kit) and a photo editor for recreating anime shots.
- Google sign-in and JSON cloud backup.

### Changed
- Clean-architecture pass: UI decoupled from the database behind repositories, Riverpod code generation, unified save-error handling.

### Fixed
- Editing no longer wipes `createdAt` or the offline-cache flag; saving a new anime or tag navigates back; the app boots even if Firebase init fails; the database closes on dispose.

### Known issues
- Photo re-edit overwrites the source (#17), camera crash on background/resume (#16), wrong trailing days in the calendar (#20), leaked dialog controllers (#19).

[0.1.2]: https://github.com/bullyee/trip_planner/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bullyee/trip_planner/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bullyee/trip_planner/releases/tag/v0.1.0
