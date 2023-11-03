---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "Cannot find instance of a LibStub")

local AceConfigDialog = --[[---@type LibAceConfigDialogDef]] LibStub("AceConfigDialog-3.0")

---@class MasterTradeSkills_Options
---@field __application string
---@field __frame AceGUIFrameDef
MasterTradeSkills_Options = {}

---@param db MasterTradeSkillsDBOptions
---@return table<string, table>
local function GetSortedTradeSkillsOptionsTable(db)
    ---@param a {id: string, name: string}
    ---@param b {id: string, name: string}
    ---@return boolean
    local function compare(a, b)
        return a.name < b.name
    end

    local trade_skills = MasterTradeSkills_Database:GetTradeSkills()
    table.sort(trade_skills, compare)

    ---@type table<string, table>
    local options = {}
    for i, trade_skill in ipairs(trade_skills) do
        options[trade_skill.id] = {
            order = i,
            type = "toggle",
            name = trade_skill.name,
            ---@param info {option: {arg: ProfessionId}}
            get = function(info) return db.ShowSkillsByTradeSkill[info.option.arg] end,
            ---@param info {option: {arg: ProfessionId}}
            set = function(info, value) db.ShowSkillsByTradeSkill[info.option.arg] = value end,
            arg = trade_skill.id,
        }
    end

    return options
end

---@param db MasterTradeSkillsDBOptions
---@return LibAceConfigOptionsTable
local function MakeOptionsTable(db)
    local trade_skills_options_table = GetSortedTradeSkillsOptionsTable(db)
    return {
        type = "group",
        name = MTS_TITLE,
        args = {
            Enable = {
                order = 0,
                type = "group",
                name = "Enable", -- TODO rename
                args = {
                    EnhanceTooltips = {
                        order = 0,
                        type = "toggle",
                        name = "Enhance tooltips", -- TODO translate
                        get = function(info) return db.EnhanceTooltips end,
                        set = function(info, value) db.EnhanceTooltips = value end,
                    },
                    EnhanceTooltipsOnlyWhileShiftIsPressed = {
                        order = 1,
                        type = "toggle",
                        name = "Enhance tooltips only while Shift is pressed", -- TODO translate
                        width = "full",
                        get = function(info) return db.EnhanceTooltipsOnlyWhileShiftIsPressed end,
                        set = function(info, value) db.EnhanceTooltipsOnlyWhileShiftIsPressed = value end,
                    },
                    EnhanceMinimapNodesTooltips = {
                        order = 2,
                        type = "toggle",
                        name = "Enhance minimap nodes tooltips", -- TODO translate
                        width = "full",
                        get = function(info) return db.EnhanceMinimapNodesTooltips end,
                        set = function(info, value) db.EnhanceMinimapNodesTooltips = value end,
                    },
                },
            },
            TradeSkills = {
                order = 1,
                type = "group",
                name = "Trade Skills", -- TODO translate
                args = trade_skills_options_table,
            },
            Difficulty = {
                order = 2,
                type = "group",
                name = "Skill Difficulty", -- TODO translate
                args = {
                    Trivial = {
                        order = 0,
                        type = "toggle",
                        name = MTS_DIF1,
                        get = function(info) return db.ShowSkillsByDifficulty.Trivial end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Trivial = value end,
                    },
                    Easy = {
                        order = 1,
                        type = "toggle",
                        name = MTS_DIF2,
                        get = function(info) return db.ShowSkillsByDifficulty.Easy end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Easy = value end,
                    },
                    Medium = {
                        order = 2,
                        type = "toggle",
                        name = MTS_DIF3,
                        get = function(info) return db.ShowSkillsByDifficulty.Medium end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Medium = value end,
                    },
                    Optimal = {
                        order = 3,
                        type = "toggle",
                        name = MTS_DIF4,
                        get = function(info) return db.ShowSkillsByDifficulty.Optimal end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Optimal = value end,
                    },
                    Difficult = {
                        order = 4,
                        type = "toggle",
                        name = MTS_DIF5,
                        get = function(info) return db.ShowSkillsByDifficulty.Difficult end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Difficult = value end,
                    },
                },
            },
            Details = {
                order = 3,
                type = "group",
                name = "Details", -- TODO translate
                args = {
                    ShowLearnedSkills = {
                        order = 0,
                        type = "toggle",
                        name = MTS_OPT_SHOWLEARNED, -- TODO skills, not recipes
                        get = function(info) return db.ShowSkillsByStatus.Learned end,
                        set = function(info, value) db.ShowSkillsByStatus.Learned = value end,
                    },
                    ShowNotLearnedSkills = {
                        order = 1,
                        type = "toggle",
                        width = "full",
                        name = MTS_OPT_SHOWNOTLEARNED, -- TODO skills, not recipes
                        get = function(info) return db.ShowSkillsByStatus.NotLearned end,
                        set = function(info, value) db.ShowSkillsByStatus.NotLearned = value end,
                    },
                    ShowAltName = {
                        order = 3,
                        type = "toggle",
                        name = MTS_OPT_ALTNAME,
                        get = function(info) return db.ShowAltName end,
                        set = function(info, value) db.ShowAltName = value end,
                    },
                    HowManySkillsToShow = {
                        order = 4,
                        type = "range",
                        name = "How many skills to show in the tooltip", -- TODO translate
                        width = "full",
                        min = 0,
                        max = 100,
                        step = 1,
                        bigStep = 1,
                        get = function(info) return db.HowManySkillsToShow end,
                        set = function(info, value) db.HowManySkillsToShow = value end,
                    },
                },
            },
            Sorting = {
                order = 4,
                type = "group",
                name = "Sorting",
                args = {
                    HigherLevelSkillsFirst = {
                        order = 0,
                        type = "toggle",
                        name = "Higher level skills first", -- TODO translate
                        get = function(info) return db.SortingOptions.HigherLevelSkillsFirst end,
                        set = function(info, value) db.SortingOptions.HigherLevelSkillsFirst = value end,
                    },
                    NotLearnedSkillsLast = {
                        order = 0,
                        type = "toggle",
                        name = "Not learned skills last", -- TODO translate
                        get = function(info) return db.SortingOptions.NotLearnedSkillsLast end,
                        set = function(info, value) db.SortingOptions.NotLearnedSkillsLast = value end,
                    },
                },
            },
            Options = {
                type = "execute",
                name = "Open options", -- TODO translate
                guiHidden = true,
                func = function()
                    MasterTradeSkills_Options:OpenDialog()
                end
            },
        },
    }
end

---@param app_name string
---@param frame Frame
local function SupportClosingWithEscape(app_name, frame)
    local name = app_name .. "OptionsFrame"
    setglobal(name, frame)
    tinsert(UISpecialFrames, name)
end

---@param application string
---@param database MasterTradeSkillsDBOptions
---@param AceConfig LibAceConfigEmbedDef
function MasterTradeSkills_Options:Initialize(application, database, AceConfig)
    AceConfig:RegisterOptionsTable(application, MakeOptionsTable(database), "mts")
    AceConfigDialog:AddToBlizOptions(application)
    self.__application = application

    local AceGUI = --[[---@type LibAceGUIDef]] LibStub("AceGUI-3.0")
    local frame = AceGUI:Create("Frame")
    AceConfigDialog:Open(application, frame)
    frame:Hide()
    SupportClosingWithEscape(application, frame.frame)
    self.__frame = frame
end

function MasterTradeSkills_Options:OpenDialog()
    self.__frame:Show()
    AceConfigDialog:Open(self.__application, self.__frame)
end
