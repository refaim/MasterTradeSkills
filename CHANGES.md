### v2.4.3 (2025/06/06)
- Update tooltip data when levelling up profession and learning new skills

### v2.4.2 (2025/05/30)
- Update LibCrafts, LibCraftingProfessions and LibItemTooltip

### v2.4.1 (2025/05/30)
- Update LibCraftingProfessions

### v2.4 (2025/05/03)
- Support Turtle WoW Jewelcrafting profession (thanks to [KasVital](https://github.com/KasVital))
- Support esMX and ptBR database locales

### v2.3 (2024/11/09)
- Update LibCrafts
- Fix some minor code issues

### v2.2 (2024/11/03)
- Support new Turtle WoW recipes for Vanilla professions

### v2.1 (2024/11/02)
- Get rid of ReagentData dependency and migrate to LibCrafts to make the database maintenance significantly easier
- Remove embedded skill localization tables and use LibCrafts for that too
- Migrate from tooltip text parsing to item id extracting to improve performance and reliability
- Drop minimap nodes tooltip enhancing feature (unfortunately)

### v2.0 (2024/10/15)
- Rewrite and refactor addon using Ace3v framework
- Use separate library to scan for the known recipes
- Drop legacy addon (Healpoints, LinkWrangler) compatibility
- Temporarily drop recipe list window to significantly simplify source code
- Fix numerous sorting, filtering and coloring bugs

### v1.12.5 (2024/02/09)
- Fix "Soul Bag" -> "Soul Pouch" name
- Add missing "Gyrofreeze Ice Reflector" name and the German localization

### v1.12.4 (2023/11/01)
- Ignore quest chat links
- Fix localization file Lua errors
- Fix TOC file format
- Add option to show tooltip only while holding Shift

### v1.12.3 (2006/10/29)
- added Healpoints Compatibility

### v1.12.2 (2006/09/30)
- added a large localization file for frFR client - (Thanks to Tigaa)

### v1.12.1c (2006/09/17)
- update to deDE Localization

### v1.12.1 (2006/08/30)
- included compatibility with Link Wrangler
- added localisation fix for deDE
- added AltNames to RecipeList to match filter

### v1.12 (2006/08/24)
- updated TOC to patch 1.12
- fixed a bug involving non-english clients
- fixed a bug affecting all small items
- added a large localization file for deDE client - (Thanks to Farook)
- added option to hide minimap recipes
- added option to move unknown recipes to bottom
- added option to hide alt character names
- added window displaying all recipes with no filters use /MTS Show

### v1.11.2 (2006/08/18)
- added a realm and faction check to alts known recipes
- added recipe info to chat link popups
- added german localization - Thanks Farook

### v1.11.1a (2006/08/16)
- small update fixing a silly error
- added a few more mining ores

### v1.11.1 (2006/08/16)
- added alts to list if not known by current char
- added tooltips to mouseovers on any useful mouseovers I could find

### v1.11 (2006/08/09) - updated by Triadian
- added bindings file so that the config screen can be bound to a key
- added loads more config options for filtering out by skill level
- added max number of lines to show in tooltip
- added reverse sorting options

### v1.09.1b
- Fixed a few bugs
- No more errors with pet training window
- Should give no more nil errors at MasterTradeSkills.lua:439
- Fixed a typo

### v1.09.1a (Release From DaDaemon)
- initial release
