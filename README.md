# Hidden Bonus

A lightweight World of Warcraft addon that hides the bonus roll prompt for content you don't want to spend a bonus roll on.

---

## What it does

With nothing checked, Hidden Bonus shows every bonus roll prompt as usual. Once you check raid bosses, Mythic+ dungeons, or Delves, only the checked content keeps its prompt and every other bonus roll is hidden, including content that isn’t in the lists (world bosses, older raids).

Type **`/hb`** or **`/hiddenbonus`** to open the options window, which has three lists:

- **Raid Bosses** — every boss in the current raid tier, read live from the Encounter Journal.
- **Mythic+ Dungeons** — every dungeon in the current Mythic+ season pool.
- **Delves** — a single switch to show bonus rolls from Bountiful Delves.

Because the raid and dungeon lists are built from live game data (Encounter Journal + `C_ChallengeMode.GetMapTable()`), a new raid tier or Mythic+ season needs no addon update — the lists update themselves the next time you open the window.

---

## Target Client

Retail World of Warcraft, current patch.

---

## Installation

Copy the `HiddenBonus` folder into your `World of Warcraft/_retail_/Interface/AddOns/` directory.
