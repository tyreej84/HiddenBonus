# Hidden Bonus

A lightweight World of Warcraft addon that hides the bonus roll prompt for content you don't want to spend a bonus roll on.

---

## What it does

When a bonus roll prompt appears after a raid boss, a Mythic+ key, or a Bountiful Delve, Hidden Bonus checks it against your choices and hides the prompt if you've marked that content as skipped. Unmarked content shows the prompt as normal.

Type **`/hb`** or **`/hiddenbonus`** to open the options window, which has three lists:

- **Raid Bosses** — every boss in the current raid tier, read live from the Encounter Journal.
- **Mythic+ Dungeons** — every dungeon in the current Mythic+ season pool.
- **Delves** — a single switch to hide bonus rolls from all Bountiful Delves.

Check a box to hide the bonus roll prompt for that boss or dungeon. Uncheck it to see the prompt again.

Because the raid and dungeon lists are built from live game data (Encounter Journal + `C_ChallengeMode.GetMapTable()`), a new raid tier or Mythic+ season needs no addon update — the lists update themselves the next time you open the window.

---

## Target Client

Retail World of Warcraft, current patch.

---

## Installation

Copy the `HiddenBonus` folder into your `World of Warcraft/_retail_/Interface/AddOns/` directory.
