setfenv(1, MasterTradeSkills)

---@class MasterTradeSkills_LegacyDatabase
MasterTradeSkills_LegacyDatabase = {}

---@shape _MtsLegacyDBOptions
---@field MTS_STATE number|nil
---@field MTS_SHOWONSHIFTKEYDOWN number|nil
---@field MTS_MOUSEOVER number|nil
---@field MTS_SHOWDIF1 number|nil
---@field MTS_SHOWDIF2 number|nil
---@field MTS_SHOWDIF3 number|nil
---@field MTS_SHOWDIF4 number|nil
---@field MTS_SHOWDIF5 number|nil
---@field MTS_SHOWLEARNED number|nil
---@field MTS_SHOWNOTLEARNED number|nil
---@field MTS_SHOWREV number|nil
---@field MTS_UNKNOWNTOBOTTOM number|nil
---@field MTS_ALTNAME number|nil
---@field MTS_NUMTOSHOW number
---@field MTS_SHOW_TRADESKILLS table<number, number>

---@shape _MtsLegacyDBCharacter
---@field Name string
---@field Realm string
---@field Faction string
---@field Options _MtsLegacyDBOptions

---@alias _MtsLegacyTradeSkill table<string, {LearntBy: table<number, string>}>

---@shape _MtsLegacyDB
---@field Characters _MtsLegacyDBCharacter[]

local INDEX_TO_TRADE_SKILL = {
    [1] = "Cooking",
    [2] = "Tailoring",
    [3] = "Enchanting",
    [4] = "Leatherworking",
    [5] = "Blacksmithing",
    [6] = "Alchemy",
    [7] = "Engineering",
    [8] = "First Aid",
    [9] = "Mining",
    [10] = "Poisons",
    [11] = "Jewelcrafting",
}

---@param defaults MasterTradeSkillsDBOptions
---@return MasterTradeSkillsDBOptions|nil
function MasterTradeSkills_LegacyDatabase:ImportOptions(defaults)
    local name, _ = UnitName("player")
    local realm = GetRealmName()
    local faction, _ = UnitFactionGroup("player")

    ---@type _MtsLegacyDBCharacter
    local player
    ---@type _MtsLegacyDB
    local database = getglobal("MTS_DATA")
    if type(database) ~= "table" then
        return nil
    end

    for _, character in ipairs(database.Characters or {}) do
        if type(character) == "table" and character.Name == name and character.Realm == realm and (character.Faction == faction or faction == nil) then
            player = character
            break
        end
    end
    if player == nil then
        return nil
    end

    local ldb = player.Options
    if type(ldb) ~= "table" or next(ldb) == nil then
        return nil
    end

    ---@param n number|nil
    ---@return boolean
    local function to_boolean(n, default)
        if n == nil then
            return default
        end
        return n == 1
    end

    ---@type table<string, boolean>
    local ShowSkillsByTradeSkill = {}
    for i, trade_skill in pairs(INDEX_TO_TRADE_SKILL) do
        ShowSkillsByTradeSkill[trade_skill] = to_boolean(ldb.MTS_SHOW_TRADESKILLS[i], defaults.ShowSkillsByTradeSkill[trade_skill])
    end
    for trade_skill, value in pairs(defaults.ShowSkillsByTradeSkill) do
        if ShowSkillsByTradeSkill[trade_skill] == nil then
            ShowSkillsByTradeSkill[trade_skill] = value
        end
    end

    local how_many_skills_to_show = ldb.MTS_NUMTOSHOW or 0
    if how_many_skills_to_show < 1 or how_many_skills_to_show > 100 then
        how_many_skills_to_show = defaults.HowManySkillsToShow
    end

    ---@type MasterTradeSkillsDBOptions
    local imported_options = {
        EnhanceTooltips = to_boolean(ldb.MTS_STATE, defaults.EnhanceTooltips),
        EnhanceTooltipsOnlyWhileShiftIsPressed = to_boolean(ldb.MTS_SHOWONSHIFTKEYDOWN, defaults.EnhanceTooltipsOnlyWhileShiftIsPressed),
        ShowSkillsByTradeSkill = ShowSkillsByTradeSkill,
        ShowSkillsByDifficulty = {
            Trivial = to_boolean(ldb.MTS_SHOWDIF1, defaults.ShowSkillsByDifficulty.Trivial),
            Easy = to_boolean(ldb.MTS_SHOWDIF2, defaults.ShowSkillsByDifficulty.Easy),
            Medium = to_boolean(ldb.MTS_SHOWDIF3, defaults.ShowSkillsByDifficulty.Medium),
            Optimal = to_boolean(ldb.MTS_SHOWDIF4, defaults.ShowSkillsByDifficulty.Optimal),
            Difficult = to_boolean(ldb.MTS_SHOWDIF5, defaults.ShowSkillsByDifficulty.Difficult),
        },
        ShowSkillsByStatus = {
            Learned = to_boolean(ldb.MTS_SHOWLEARNED, defaults.ShowSkillsByStatus.Learned),
            NotLearned = to_boolean(ldb.MTS_SHOWNOTLEARNED, defaults.ShowSkillsByStatus.NotLearned),
        },
        SortingOptions = {
            HigherLevelSkillsFirst = to_boolean(ldb.MTS_SHOWREV, defaults.SortingOptions.HigherLevelSkillsFirst),
            NotLearnedSkillsLast = to_boolean(ldb.MTS_UNKNOWNTOBOTTOM, defaults.SortingOptions.NotLearnedSkillsLast),
        },
        ShowAltName = to_boolean(ldb.MTS_ALTNAME, defaults.ShowAltName),
        ShowCrossFactionAlts = false,
        HowManySkillsToShow = how_many_skills_to_show,
    }

    player.Options = --[[---@type _MtsLegacyDBOptions]] {}

    return imported_options
end

function MasterTradeSkills_LegacyDatabase:Clear()
    ---@type table<string, any>
    local G = getfenv(0)
    G['MTS_DATA'] = nil
end
