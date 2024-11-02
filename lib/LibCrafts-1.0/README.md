# LibCrafts

A modern, lightweight embeddable database library for crafting professions in Vanilla WoW (1.12.1) and [Turtle WoW](https://turtle-wow.org). Designed as an replacement (not a drop-in) for [ReagentData](https://github.com/refaim/ReagentData), [TradeSkillsData](https://github.com/refaim/TradeSkillsData) and [TradeSkillsData-turtle](https://github.com/refaim/TradeSkillsData-turtle).

## Features

- Lightweight ID-based database architecture
- Complete crafting system mapping (spells, recipes, reagents, results, sources etc)
- Developer-friendly database structure
- Vanilla WoW and Turtle WoW compatibility
- Localization support

## Usage

```lua
local LibCrafts = LibStub("LibCrafts-1.0")

-- Query crafts using reagent ID
local reagentId = 2318 -- Light Leather, see https://www.wowhead.com/classic/item=2318/light-leather
local crafts = LibCraftingProfessions:GetCraftsByReagentId(reagentId) -- Light Leather
```

## Contributing

If you have suggestions for improvements or have found a bug, please create an issue or submit a pull request.

## License

LibCrafts is distributed under the MIT License. For details, see the [LICENSE](LICENSE) file.
