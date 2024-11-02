setfenv(1, MasterTradeSkills)

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "Cannot find instance of a LibStub")

local AceConfigDialog, _ = LibStub("AceConfigDialog-3.0")
local LibCraftingProfessions = --[[---@type LibCraftingProfessions]] LibStub("LibCraftingProfessions-1.0")

---@class MasterTradeSkills_Options
---@field __application string
---@field __frame AceGUIFrameDef
MasterTradeSkills_Options = {}

---@param db MasterTradeSkillsDBOptions
---@return table<string, table>
local function GetSortedTradeSkillsOptionsTable(db)
    ---@param a LcpProfession
    ---@param b LcpProfession
    ---@return boolean
    local function compare(a, b)
        return a.localized_name < b.localized_name
    end

    local trade_skills = LibCraftingProfessions:GetSupportedProfessions()
    table.sort(trade_skills, compare)

    ---@type table<string, table>
    local options = {}
    for i, trade_skill in ipairs(trade_skills) do
        options[trade_skill.localized_name] = {
            order = i,
            type = "toggle",
            name = trade_skill.localized_name,
            ---@param info {option: {arg: string}}
            get = function(info) return db.ShowSkillsByTradeSkill[info.option.arg] end,
            ---@param info {option: {arg: string}}
            set = function(info, value) db.ShowSkillsByTradeSkill[info.option.arg] = value end,
            arg = trade_skill.localized_name,
        }
    end

    return options
end

---@param L MasterTradeSkillsLocale
---@param db MasterTradeSkillsDBOptions
---@return LibAceConfigOptionsTable
local function MakeOptionsTable(L, db)
    local trade_skills_options_table = GetSortedTradeSkillsOptionsTable(db)
    return {
        type = "group",
        name = format("%s v%s", MtsAddonName, MtsAddonVersion),
        args = {
            Enable = {
                order = 0,
                type = "group",
                name = L.txt_option_group_enable,
                args = {
                    EnhanceTooltips = {
                        order = 0,
                        type = "toggle",
                        name = L.txt_option_enhance_tooltips,
                        get = function(info) return db.EnhanceTooltips end,
                        set = function(info, value) db.EnhanceTooltips = value end,
                    },
                    EnhanceTooltipsOnlyWhileShiftIsPressed = {
                        order = 1,
                        type = "toggle",
                        name = L.txt_option_enhance_tooltips_shift,
                        width = "full",
                        get = function(info) return db.EnhanceTooltipsOnlyWhileShiftIsPressed end,
                        set = function(info, value) db.EnhanceTooltipsOnlyWhileShiftIsPressed = value end,
                    },
                },
            },
            TradeSkills = {
                order = 1,
                type = "group",
                name = L.txt_option_group_trade_skills,
                args = trade_skills_options_table,
            },
            Difficulty = {
                order = 2,
                type = "group",
                name = L.txt_option_group_skill_difficulty,
                args = {
                    Trivial = {
                        order = 0,
                        type = "toggle",
                        name = L.txt_option_show_trivial,
                        get = function(info) return db.ShowSkillsByDifficulty.Trivial end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Trivial = value end,
                    },
                    Easy = {
                        order = 1,
                        type = "toggle",
                        name = L.txt_option_show_easy,
                        get = function(info) return db.ShowSkillsByDifficulty.Easy end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Easy = value end,
                    },
                    Medium = {
                        order = 2,
                        type = "toggle",
                        name = L.txt_option_show_medium,
                        get = function(info) return db.ShowSkillsByDifficulty.Medium end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Medium = value end,
                    },
                    Optimal = {
                        order = 3,
                        type = "toggle",
                        name = L.txt_option_show_optimal,
                        get = function(info) return db.ShowSkillsByDifficulty.Optimal end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Optimal = value end,
                    },
                    Difficult = {
                        order = 4,
                        type = "toggle",
                        name = L.txt_option_show_difficult,
                        get = function(info) return db.ShowSkillsByDifficulty.Difficult end,
                        set = function(info, value) db.ShowSkillsByDifficulty.Difficult = value end,
                    },
                },
            },
            Details = {
                order = 3,
                type = "group",
                name = L.txt_option_group_details,
                args = {
                    ShowLearnedSkills = {
                        order = 0,
                        type = "toggle",
                        name = L.txt_option_show_learned,
                        get = function(info) return db.ShowSkillsByStatus.Learned end,
                        set = function(info, value) db.ShowSkillsByStatus.Learned = value end,
                    },
                    ShowNotLearnedSkills = {
                        order = 1,
                        type = "toggle",
                        width = "full",
                        name = L.txt_option_show_not_learned,
                        get = function(info) return db.ShowSkillsByStatus.NotLearned end,
                        set = function(info, value) db.ShowSkillsByStatus.NotLearned = value end,
                    },
                    ShowAltName = {
                        order = 3,
                        type = "toggle",
                        name = L.txt_option_show_alt_name,
                        get = function(info) return db.ShowAltName end,
                        set = function(info, value) db.ShowAltName = value end,
                    },
                    ShowCrossFactionAlts = {
                        order = 4,
                        type = "toggle",
                        name = L.txt_option_show_cross_faction_alts,
                        get = function(info) return db.ShowCrossFactionAlts end,
                        set = function(info, value) db.ShowCrossFactionAlts = value end,
                    },
                    HowManySkillsToShow = {
                        order = 5,
                        type = "range",
                        name = L.txt_option_how_many_skills_to_show,
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
                name = L.txt_option_group_sorting,
                args = {
                    HigherLevelSkillsFirst = {
                        order = 0,
                        type = "toggle",
                        name = L.txt_option_higher_level_skills_first,
                        get = function(info) return db.SortingOptions.HigherLevelSkillsFirst end,
                        set = function(info, value) db.SortingOptions.HigherLevelSkillsFirst = value end,
                    },
                    NotLearnedSkillsLast = {
                        order = 0,
                        type = "toggle",
                        name = L.txt_option_not_learned_skills_last,
                        get = function(info) return db.SortingOptions.NotLearnedSkillsLast end,
                        set = function(info, value) db.SortingOptions.NotLearnedSkillsLast = value end,
                    },
                },
            },
            Options = {
                type = "execute",
                name = L.txt_open_options,
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
    tinsert(UISpecialFrames, name) -- close with Escape key
end

---@param L MasterTradeSkillsLocale
---@param application string
---@param database MasterTradeSkillsDBOptions
---@param AceConfig LibAceConfigEmbedDef
function MasterTradeSkills_Options:Initialize(L, application, database, AceConfig)
    AceConfig:RegisterOptionsTable(application, MakeOptionsTable(L, database), "mts")
    AceConfigDialog:AddToBlizOptions(application)
    self.__application = application

    local AceGUI, _ = LibStub("AceGUI-3.0")
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
