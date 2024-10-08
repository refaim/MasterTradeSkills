# LibCraftingProfessions

LibCraftingProfessions is a small library designed to provide a universal interface for crafting professions in Vanilla WoW (version 1.12.1). The library encapsulates interactions with the game's user interface, allowing addon developers to easily retrieve information about character professions and skills.

## Key Features

- Universal interface for both CraftFrame-based and TradeSkillFrame-based professions
- Retrieve a list of character professions
- Get a list of known skills for each profession
- Clean data from non-obvious peculiarities of the game interface
- Cache data for using by multiple addons

## Usage examples

```lua
local LibCraftingProfessions = LibStub("LibCraftingProfessions-1.0")

-- Get the list of all supported crafting professions
local professions = LibCraftingProfessions:GetSupportedProfessions()

-- Get the list of player crafting professions
local player_professions = LibCraftingProfessions:GetPlayerProfessions()

-- Get player skills for a specific profession
local skills = LibCraftingProfessions:GetPlayerProfessionSkills("Blacksmithing")

--- Listen for the profession skills update event
LibCraftingProfessions:RegisterEvent("LCP_SKILLS_UPDATE", function(profession, skills)
    print(profession.localized_name)
    for _, skill in ipairs(skills) do
        print(skill.localized_name)
    end
end)
```

## Contributing

If you have suggestions for improvements or have found a bug, please create an issue or submit a pull request.

## License

LibCraftingProfessions is distributed under the MIT License. For details, see the [LICENSE](LICENSE) file.
