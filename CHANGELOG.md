# Changelog

All notable changes to **Hidden Bonus** are documented in this file.

---

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
