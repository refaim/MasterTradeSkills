setfenv(1, MasterTradeSkills)

---@class MasterTradeSkills_Database
---@field _db _MasterTradeSkillsDB
---@field _lib_ace_db LibAceDBDef
---@field _lib_crafting_professions LibCraftingProfessions
MasterTradeSkills_Database = {}

---@shape MasterTradeSkillsDBDifficultyOptions
---@field Trivial boolean
---@field Easy boolean
---@field Medium boolean
---@field Optimal boolean
---@field Difficult boolean

---@shape MasterTradeSkillsDBStatusOptions
---@field Learned boolean
---@field NotLearned boolean

---@shape MasterTradeSkillsDBSortingOptions
---@field HigherLevelSkillsFirst boolean
---@field NotLearnedSkillsLast boolean

---@shape MasterTradeSkillsDBOptions
---@field EnhanceTooltips boolean
---@field EnhanceTooltipsOnlyWhileShiftIsPressed boolean
---@field ShowSkillsByTradeSkill table<string, boolean>
---@field ShowSkillsByDifficulty MasterTradeSkillsDBDifficultyOptions
---@field ShowSkillsByStatus MasterTradeSkillsDBStatusOptions
---@field SortingOptions MasterTradeSkillsDBSortingOptions
---@field ShowAltName boolean
---@field ShowCrossFactionAlts boolean
---@field HowManySkillsToShow number

---@shape MasterTradeSkillsDBCharacter
---@field realm string
---@field faction string
---@field name string
---@field profession_to_skill_to_difficulty table<string, table<string, string>>>

---@shape _MasterTradeSkillsDB
---@field char {Options: MasterTradeSkillsDBOptions}
---@field global {RealmToNameToCharacter: table<string, table<string, MasterTradeSkillsDBCharacter>>}

---@param lib_ace_db LibAceDBDef
---@param lib_crafting_professions LibCraftingProfessions
function MasterTradeSkills_Database:Initialize(lib_ace_db, lib_crafting_professions)
    self._lib_ace_db = lib_ace_db
    self._lib_crafting_professions = lib_crafting_professions

    local default_options = self:_GetDefaultOptions()

    ---@type _MasterTradeSkillsDB
    local defaults = {
        char = {
            Options = MasterTradeSkills_LegacyDatabase:ImportOptions(default_options) or default_options,
        },
        global = {
            RealmToNameToCharacter = {
                ["*"] = {
                    ["*"] = {
                        ["realm"] = "",
                        ["faction"] = "",
                        ["name"] = "",
                        ["profession_to_skill_to_difficulty"] = {
                            ["*"] = {}
                        }
                    },
                }
            },
        },
    }
    MasterTradeSkills_LegacyDatabase:Clear()

    self._db = --[[---@type _MasterTradeSkillsDB]] self._lib_ace_db:New("MasterTradeSkillsData", defaults)

    return self
end

---@return MasterTradeSkillsDBOptions
function MasterTradeSkills_Database:_GetDefaultOptions()
    ---@type table<string, boolean>
    local show_skills_by_trade_skill = {}
    for _, trade_skill in ipairs(self._lib_crafting_professions:GetSupportedProfessions()) do
        show_skills_by_trade_skill[trade_skill.localized_name] = true
    end

    return {
        EnhanceTooltips = true,
        EnhanceTooltipsOnlyWhileShiftIsPressed = false,
        ShowSkillsByTradeSkill = show_skills_by_trade_skill,
        ShowSkillsByDifficulty = {
            Trivial = true,
            Easy = true,
            Medium = true,
            Optimal = true,
            Difficult = true,
        },
        ShowSkillsByStatus = {
            Learned = true,
            NotLearned = true,
        },
        SortingOptions = {
            HigherLevelSkillsFirst = true,
            NotLearnedSkillsLast = true,
        },
        ShowAltName = true,
        ShowCrossFactionAlts = false,
        HowManySkillsToShow = 10,
    }
end

---@return MasterTradeSkillsDBOptions
function MasterTradeSkills_Database:GetOptions()
    return self._db.char.Options
end

---@return MasterTradeSkillsDBCharacter
function MasterTradeSkills_Database:GetOrCreatePlayer()
    local realm = GetRealmName()
    local name, _ = UnitName("player")
    local faction, _ = UnitFactionGroup("player")

    local player = self._db.global.RealmToNameToCharacter[realm][name]
    player.realm = realm
    player.faction = faction
    player.name = name
    return player
end

---@return MasterTradeSkillsDBCharacter[]
function MasterTradeSkills_Database:GetOtherCharactersFromCurrentRealm()
    local player = self:GetOrCreatePlayer()

    local other_characters = {}
    for _, character in pairs(self._db.global.RealmToNameToCharacter[player.realm]) do
        local match_by_faction = character.faction == player.faction or self._db.char.Options.ShowCrossFactionAlts
        if character.name ~= player.name and match_by_faction then
            tinsert(other_characters, character)
        end
    end

    return other_characters
end

---@param profession LcpKnownProfession
---@param skills LcpKnownSkill[]
function MasterTradeSkills_Database:SavePlayerSkills(profession, skills)
    local player = self:GetOrCreatePlayer()

    ---@type table<string, string>
    local skill_to_difficulty = {}
    for _, skill in ipairs(skills) do
        skill_to_difficulty[skill.localized_name] = skill.difficulty
    end
    player.profession_to_skill_to_difficulty[profession.localized_name] = skill_to_difficulty

    self:_ForgetObsoleteProfessions(player)
end

---@param player MasterTradeSkillsDBCharacter
function MasterTradeSkills_Database:_ForgetObsoleteProfessions(player)
    local known_professions = self._lib_crafting_professions:GetPlayerProfessions()
    if known_professions == nil then
        return
    end

    ---@type table<string, true>
    local known_profession_localized_name_set = {}

    ---@type table<string, boolean>
    for _, known_profession in ipairs(--[[---@not nil]] known_professions) do
        known_profession_localized_name_set[known_profession.localized_name] = true
    end

    for saved_profession_localized_name, _ in pairs(player.profession_to_skill_to_difficulty) do
        if known_profession_localized_name_set[saved_profession_localized_name] == nil then
            player.profession_to_skill_to_difficulty[saved_profession_localized_name] = nil
        end
    end
end
