---@class MasterTradeSkills_LegacyDatabase
MasterTradeSkills_LegacyDatabase = {}

---@shape MasterTradeSkillsLegacyDBOptions
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

---@shape MasterTradeSkillsLegacyDBCharacter
---@field Name string
---@field Realm string
---@field Faction string
---@field Options MasterTradeSkillsLegacyDBOptions

---@alias MasterTradeSkillsLegacyDB {Characters: MasterTradeSkillsLegacyDBCharacter[]}

---@param defaults MasterTradeSkillsDBOptions
---@return MasterTradeSkillsDBOptions|nil
function MasterTradeSkills_LegacyDatabase:ImportOptions(defaults)
    local name, _ = UnitName("player")
    assert(name ~= nil)
    local realm = GetRealmName()
    assert(realm ~= nil)
    local faction, _ = UnitFactionGroup("player")

    ---@type MasterTradeSkillsLegacyDBCharacter
    local player
    ---@type MasterTradeSkillsLegacyDB
    local database = getglobal("MTS_DATA")
    for _, character in ipairs(database.Characters or {}) do
        if character.Name == name and character.Realm == realm and (character.Faction == faction or faction == nil) then
            player = character
            break
        end
    end
    if player == nil then
        return nil
    end

    local ldb = player.Options
    if ldb == nil or type(ldb) ~= "table" or MasterTradeSkills_Utils:IsTableEmpty(ldb) then
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

    ---@type table<ProfessionId, boolean>
    local ShowSkillsByTradeSkill = {}
    for i, trade_skill_id in pairs(MTS_TSD_PROFESSION_ID) do
        ShowSkillsByTradeSkill[trade_skill_id] = to_boolean(ldb.MTS_SHOW_TRADESKILLS[i], defaults.ShowSkillsByTradeSkill[trade_skill_id])
    end
    for trade_skill_id, value in pairs(defaults.ShowSkillsByTradeSkill) do
        if ShowSkillsByTradeSkill[trade_skill_id] == nil then
            ShowSkillsByTradeSkill[trade_skill_id] = value
        end
    end

    -- Option was called "No Minimap Recipes", so we should inverse the value
    local EnhanceMinimapNodesTooltips = defaults.EnhanceMinimapNodesTooltips
    if type(ldb.MTS_MOUSEOVER) == "number" then
        EnhanceMinimapNodesTooltips = ldb.MTS_MOUSEOVER == 0
    end

    ---@type MasterTradeSkillsDBOptions
    local imported_options = {
        EnhanceTooltips = to_boolean(ldb.MTS_STATE, defaults.EnhanceTooltips),
        EnhanceTooltipsOnlyWhileShiftIsPressed = to_boolean(ldb.MTS_SHOWONSHIFTKEYDOWN, defaults.EnhanceTooltipsOnlyWhileShiftIsPressed),
        EnhanceMinimapNodesTooltips = EnhanceMinimapNodesTooltips,
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
        HowManySkillsToShow = ldb.MTS_NUMTOSHOW or defaults.HowManySkillsToShow,
    }

    player.Options = --[[---@type MasterTradeSkillsLegacyDBOptions]] {}

    return imported_options
end
