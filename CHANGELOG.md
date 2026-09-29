# Changelog

All notable changes to **Hidden Bonus** are documented in this file.

---

## [1.1.2] - 2026-09-29

### Changed

- With nothing checked, every bonus roll prompt is now shown. Checking raid bosses, Mythic+ dungeons, or Delves shows the prompt only for the checked content and hides every other bonus roll, including content that isn’t listed (world bosses, older raids).
- Checks saved for bosses or dungeons that are no longer in the current lists are ignored, so an old tier’s selection can’t hide everything.

### Fixed

- An empty Mythic+ dungeon list is no longer cached for the whole session.

## [1.1.1] - 2026-09-23

### Fixed

- Raid bosses column was always empty. Current Season raids in the Encounter Journal were mistaken for the world-boss entry and skipped; the world-boss entry is now identified by its expansion name instead.
- An empty raid list is no longer cached for the whole session.

### Added

- `/hb debug` prints the raid instances the Encounter Journal reports.

## [1.1.0] - 2026-09-22

### Changed

- Inverted filtering logic: everything is now hidden by default. Checking a raid boss, Mythic+ dungeon, or the Delves switch keeps the bonus roll prompt visible for that content instead of hiding it.
- Rebuilt the options window with a flat, dark, custom-drawn panel and checkboxes instead of Blizzard's stone/parchment templates.

## [1.0.0] - 2026-09-22

### Added

- Initial release. Hides the bonus roll prompt for chosen raid bosses, Mythic+ dungeons, and Delves.
- Raid boss list is read live from the Encounter Journal for the current tier.
- Mythic+ dungeon list is read live from `C_ChallengeMode.GetMapTable()` for the current season.
- Single switch to hide bonus rolls from all Bountiful Delves.
- `/hb` and `/hiddenbonus` open the options window.
