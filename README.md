# Herald Observer

A World of Warcraft addon for validating player gear eligibility for the **Herald of the Titans** achievement.

Herald of the Titans requires every player in the raid to wear gear that does not exceed item level 107, comes from Wrath of the Lich King or earlier, and includes no heirloom items. Herald Observer automates that check so you can verify any player in seconds.

---

## Features

- **Gear Scan** — Target any player and click Observe to instantly validate all 19 equipment slots
- **Three-rule validation** — Flags items that exceed ilvl 107, come from a post-WotLK expansion, or are heirlooms
- **Flexible output** — Send results to yourself, whisper the target, party chat, or raid chat
- **Draggable UI** — Main window is movable and remembers its position across sessions
- **Minimap button** — Custom draggable icon for quick access; position is also saved
- **Slash command** — `/herald` toggles the UI at any time
- **Persistent settings** — All preferences saved via `SavedVariables`

---

## Installation

1. Download the latest release
2. Extract the `HeraldObserver` folder into your addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\HeraldObserver
   ```
3. Launch the game, open **AddOns** on the character select screen, and enable **Herald Observer**

---

## Usage

1. Target the player you want to check
2. Open the addon via `/herald` or by clicking the minimap button
3. Select where you want the results sent (Self / Target / Party / Raid)
4. Click **Observe**

If the player's gear is fully valid you will see:
```
PlayerName Gear OK
```

If any slot fails, each offending item is reported with its reason:
```
PlayerName ==> [Item Name] (not in whitelist, ilvl, expac, heirloom)
```

---

## Validation Rules

| Rule | Condition |
|---|---|
| Item Level | Must be ≤ 107 |
| Expansion | Must be from Wrath of the Lich King (expacID ≤ 2) or earlier |
| Heirloom | Heirloom items (quality 7) are not allowed |
| Whitelist | Item ID must be present in the curated whitelist |

---

## Slash Commands

| Command | Action |
|---|---|
| `/herald` | Toggle the Herald Observer window |

---

## Settings

All settings are stored in the `HeraldObserverDB` SavedVariable and persist across sessions:

- **Send herald info to** — output destination (self, target, party, raid)
- **Clamp To Screen** — prevents the window from being dragged off-screen
- **Show Minimap Button** — shows or hides the minimap icon
- **Frame position** — saved automatically when you drag the window
- **Minimap button angle** — saved automatically when you drag the icon

---

## Compatibility

| Version | Interface |
|---|---|
| 1.5.0 | The War Within (11.2.0) |
| 1.6.0 | Midnight (12.0.1) |

---

## Changelog

### Version 1.6.1 — Midnight Item Level Squish
- Lowered the item level cap from 107 to 41 to reflect the item level squish introduced in World of Warcraft: Midnight

### Version 1.6.0 — Midnight Compatibility
- Updated interface version to 120001 for World of Warcraft: Midnight
- Replaced deprecated `GetItemInfo()` with `C_Item.GetItemInfo()` (returns `.itemQuality` and `.expacID`)
- Replaced removed `UIDropDownMenu` API with a fully custom frame-based dropdown
- Replaced `math.atan2()` with `math.atan()` for Lua 5.3+ compatibility
- Fixed "Clamp To Screen" checkbox anchor broken by the dropdown replacement

### Version 1.5.0 — Whitelist Upgrade
- Added 383 items to the whitelist

### Version 1.4.0 — Whitelist Refinement & Minimap Button Visual Upgrade
- Curated whitelist to include only active item IDs
- Standardized minimap button size to 22×22
- Reduced addon memory footprint and improved load times

### Version 1.3.0 — Whitelist Loader Fix & UI Expansion
- Fixed whitelist not loading in-game (replaced unsupported `require()` with native global table)
- Added minimap button toggle checkbox with SavedVariables persistence
- Fixed duplicate gear scanning logic

### Version 1.2.0 — Heirloom Detection & Gear Enforcement
- Heirloom items (quality 7) are now flagged as ineligible
- Rejection messages now include the specific reason (ilvl / expac / heirloom)

### Version 1.1.0 — Persistence, Polish & Slash Commands
- All settings now persist across sessions via SavedVariables
- Added `/herald` slash command
- Minimap button drag saves position; click toggles UI
- Frame drag saves position dynamically

### Version 1.0.0 — Initial Release
- Core gear validation (ilvl ≤ 107, WotLK or earlier)
- Movable UI frame with dropdown, checkbox, and Observe button
- Custom minimap button with logo texture

---

## Author

**Fate** — thefatesaber
