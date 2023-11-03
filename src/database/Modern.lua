---@class MasterTradeSkills_Database
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
---@field EnhanceMinimapNodesTooltips boolean
---@field ShowSkillsByTradeSkill table<ProfessionId, boolean>
---@field ShowSkillsByDifficulty MasterTradeSkillsDBDifficultyOptions
---@field ShowSkillsByStatus MasterTradeSkillsDBStatusOptions
---@field SortingOptions MasterTradeSkillsDBSortingOptions
---@field ShowAltName boolean
---@field HowManySkillsToShow number

---@shape MasterTradeSkillsDB
---@field char {Options: MasterTradeSkillsDBOptions}

---@param LibStub LibStubDef
---@return MasterTradeSkillsDB
function MasterTradeSkills_Database:Initialize(LibStub)
    ---@type table<ProfessionId, boolean>
    local show_skills_by_trade_skill = {}
    for _, trade_skill in ipairs(self:GetTradeSkills()) do
        show_skills_by_trade_skill[trade_skill.id] = true
    end

    ---@type MasterTradeSkillsDBOptions
    local default_options = {
        EnhanceTooltips = true,
        EnhanceTooltipsOnlyWhileShiftIsPressed = false,
        EnhanceMinimapNodesTooltips = false,
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
        HowManySkillsToShow = 10,
    }

    local legacy_options = MasterTradeSkills_LegacyDatabase:ImportOptions(default_options)

    ---@type MasterTradeSkillsDB
    local defaults = {
        char = {
            Options = legacy_options or default_options,
        },
    }

    local AceDB = --[[---@type AceDBDef]] LibStub("AceDB-3.0")
    return --[[---@type MasterTradeSkillsDB]] AceDB:New("MasterTradeSkillsData", defaults)
end

---@return {id: ProfessionId, name: string}[]
function MasterTradeSkills_Database:GetTradeSkills()
    ---@type {id: ProfessionId, name: string}[]
    local result = {}
    for profession_id, profession in pairs(TRADE_SKILLS_DATA["professions"]) do -- TODO hide frameless professions (need to add data to TSD)
        tinsert(result, { id = profession_id, name = profession.name["English"] }) -- TODO translate
    end
    return result
end
