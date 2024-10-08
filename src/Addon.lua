setfenv(1, MasterTradeSkills)

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "Cannot find instance of a LibStub")

local AceAddon, _ = LibStub("AceAddon-3.0")

---@type AceAddonDef
---@field db MasterTradeSkills_Database
---@field options MasterTradeSkillsDBOptions
---@field reagent_to_profession_id_to_items table<string, table<string, string[]>>
---@field localized_known_crafting_profession_name_set table<string, boolean>
local MasterTradeSkills = AceAddon:NewAddon(MtsAddonName, "AceConfig-3.0", "AceHook-3.0")

local AceCore, _ = LibStub("AceCore-3.0")
local AceDB, _ = LibStub("AceDB-3.0")

local AceLocale, _ = LibStub("AceLocale-3.0")
local L = --[[---@type MasterTradeSkillsLocale]] AceLocale:GetLocale(MtsAddonName, false)
local LR = --[[---@type table<string, string>]] L

local LibCraftingProfessions = --[[---@type LibCraftingProfessions]] LibStub("LibCraftingProfessions-1.0")

---@return LibAceConfigEmbedDef
function MasterTradeSkills:AceConfig()
    return --[[---@type LibAceConfigEmbedDef]] self
end

---@return LibAceHookEmbedDef
function MasterTradeSkills:AceHook()
    return --[[---@type LibAceHookEmbedDef]] self
end

---@return void
function MasterTradeSkills:OnInitialize()
    self.db = MasterTradeSkills_Database:Initialize(AceDB, LibCraftingProfessions)
    self.db_options = self.db:GetOptions()
    MasterTradeSkills_Options:Initialize(L, MtsAddonName, self.db_options, self:AceConfig())

    local event_frame = CreateFrame("Frame", nil, GameTooltip)
    event_frame:SetScript("OnShow", function()
        self:PreHookGameTooltipOnShow()
    end)
    self:AceHook():SecureHook("SetItemRef", "PostHookSetItemRef")

    LibCraftingProfessions:RegisterEvent("LCP_SKILLS_UPDATE", function(profession, skills)
        self.db:SavePlayerSkills(profession, skills)
    end)
end

---@return void
function MasterTradeSkills:OnEnable()
    self:LoadReagentData()

    ---@type table<string, boolean>
    local localized_crafting_profession_name_set = {}
    for _, profession in ipairs(LibCraftingProfessions:GetSupportedProfessions()) do
        localized_crafting_profession_name_set[profession.localized_name] = true
    end
    self.localized_crafting_profession_name_set = localized_crafting_profession_name_set

    self:Print(L.txt_addon_loaded);
end

---@return void
function MasterTradeSkills:LoadReagentData()
    ---@type table<string, fun():void>
    local id_to_loader = {
        alchemy = ReagentData_LoadAlchemy,
        blacksmithing = ReagentData_LoadBlacksmithing,
        cooking = ReagentData_LoadCooking,
        enchanting = ReagentData_LoadEnchanting,
        engineering = ReagentData_LoadEngineering,
        firstaid = ReagentData_LoadFirstAid,
        leatherworking = ReagentData_LoadLeatherworking,
        mining = ReagentData_LoadMining,
        poisons = ReagentData_LoadPoisons,
        tailoring = ReagentData_LoadTailoring,
    }

    local reagent_data = self:GetReagentData()
    for profession_id, loader in pairs(id_to_loader) do
        if reagent_data['crafted'][profession_id] == nil then
            loader()
        end
    end

    ---@type table<string, table<string, string[]>>
    local reagent_to_profession_to_items = {}
    for profession_id, item_to_props in pairs(reagent_data['crafted']) do
            for item, item_props in pairs(item_to_props) do
                for reagent, _ in pairs(item_props['reagents']) do
                    if reagent_to_profession_to_items[reagent] == nil then
                        reagent_to_profession_to_items[reagent] = {}
                    end
                    if reagent_to_profession_to_items[reagent][profession_id] == nil then
                        reagent_to_profession_to_items[reagent][profession_id] = {}
                    end
                tinsert(reagent_to_profession_to_items[reagent][profession_id], item)
            end
        end
    end
    self.localized_reagent_to_profession_id_to_en_items = reagent_to_profession_to_items
end

---@shape ReagentDataItem
---@field skill number
---@field source string
---@field reagents table<string, number>

---@shape ReagentData
---@field crafted table<string, table<string, ReagentDataItem>>
---@field gathering table<string, string>
---@field professions table<string, string>
---@field reverseprofessions table<string, string>

---@return ReagentData
function MasterTradeSkills:GetReagentData()
    return --[[---@type ReagentData]] ReagentData
end

---@return void
function MasterTradeSkills:PostHookSetItemRef(link, text, button)
    local prefix_supported = strsub(link, 1, strlen("item")) == "item"
    if prefix_supported and not IsControlKeyDown() and not IsShiftKeyDown() then
        local name, _, _, _, _, _, _, _, _ = GetItemInfo(link);
        if name ~= nil and self:EnhanceTooltip(ItemRefTooltip, name) then
            ItemRefTooltip:Show()
        end
    end
end

---@return void
function MasterTradeSkills:PreHookGameTooltipOnShow()
    local enhance = self.db_options.EnhanceTooltips
        and (IsShiftKeyDown() or not self.db_options.EnhanceTooltipsOnlyWhileShiftIsPressed)
        and (self.db_options.EnhanceMinimapNodesTooltips or not MouseIsOver(MinimapCluster))

    if not enhance then
        return
    end

    local item = self:ExtractItemFromTooltip()
    if item ~= nil and self:EnhanceTooltip(GameTooltip, --[[---@not nil]] item) then
        GameTooltip:Show()
    end
end

---@return string|nil
function MasterTradeSkills:ExtractItemFromTooltip()
    ---@type FontString|nil
    local label = getglobal("GameTooltipTextLeft1")
    if label == nil then
        return nil
    end

    local text_or_nil = (--[[---@not nil]] label):GetText()
    if text_or_nil == nil or text_or_nil == "" then
        return nil
    end

    local text = --[[---@not nil]] text_or_nil
    local subs = 0
    for _, suffix in ipairs({"Vein", "Deposit"}) do
        text, subs = gsub(text, suffix, "Ore")
        if subs > 0 then
            break
        end
    end
    if strfind(text, "Ore", 1, true) ~= nil then
        for _, prefix in ipairs({"Small", "Rich", "Ooze Covered"}) do
            text, subs = gsub(text, prefix .. " ", "")
            if subs > 0 then
                break
            end
        end
    end

    return text
end

---@shape TooltipItemGroup
---@field localized_profession_name string
---@field my_profession_rank number|nil
---@field items TooltipItem[]

---@shape TooltipItem
---@field localized_name string
---@field localized_source string
---@field required_rank number
---@field is_reagent boolean
---@field difficulty string|nil
---@field other_character_to_difficulty table<string, string>

---@param tooltip GameTooltip
---@param item string
---@return boolean
function MasterTradeSkills:EnhanceTooltip(tooltip, item)
    local groups = self:CreateTooltipItemGroups(item)
    groups = self:FilterTooltipItemGroups(groups)
    self:SortTooltipItemGroups(groups)
    groups = self:LimitTooltipItemGroups(groups)
    if getn(groups) == 0 then
        return false
    end
    self:DrawTooltipItemGroups(tooltip, groups)
    return true
end

---@param possible_reagent string
---@return TooltipItemGroup[]
function MasterTradeSkills:CreateTooltipItemGroups(possible_reagent)
    ---@type table<string, string>
    local en_source_to_localized_source = {
        ["Drop"] = L.txt_source_drop,
        ["Quest"] = L.txt_source_quest,
        ["Trainer"] = L.txt_source_trainer,
        ["Unknown"] = L.txt_source_unknown,
        ["Vendor"] = L.txt_source_vendor,
    }

    ---@type table<string, {rank: number|nil}>
    local my_profession_localized_name_to_rank = {}
    for _, profession in ipairs(LibCraftingProfessions:GetPlayerProfessions() or {}) do
        my_profession_localized_name_to_rank[profession.localized_name] = {["rank"] = profession.cur_rank}
    end

    local reagent_data = self:GetReagentData()
    local player_db = self.db:GetOrCreatePlayer()
    ---@type TooltipItemGroup[]
    local item_groups = {}
    for profession_id, en_item_names in pairs(self.localized_reagent_to_profession_id_to_en_items[possible_reagent] or {}) do
        local localized_profession_name = reagent_data['professions'][profession_id] or reagent_data['gathering'][profession_id]
        local is_profession_supported = self.localized_crafting_profession_name_set[localized_profession_name] ~= nil
        local is_profession_enabled_in_tooltips = self.db_options.ShowSkillsByTradeSkill[localized_profession_name]
        if is_profession_supported and is_profession_enabled_in_tooltips then
            ---@type TooltipItem[]
            local group_items = {}
            for _, en_item_name in ipairs(en_item_names) do
                local item = reagent_data['crafted'][profession_id][en_item_name]
                local localized_item_name = LR[en_item_name]
                local source, _ = AceCore.strsplit(":", item.source, 2)
                local is_reagent = false
                if localized_item_name ~= nil then
                    is_reagent = getn(ReagentData_GetProfessions(localized_item_name) or {}) > 0
                else
                    self:Print(format(L.txt_missing_locale, en_item_name))
                end

                ---@type table<string, string>
                local other_character_to_difficulty = {}
                for _, character in ipairs(self.db:GetOtherCharactersFromCurrentRealm()) do
                    other_character_to_difficulty[character.name] = character.profession_to_skill_to_difficulty[localized_profession_name][localized_item_name]
                end

                ---@type TooltipItem
                local tooltip_item = {
                    localized_name = localized_item_name or en_item_name,
                    localized_source = en_source_to_localized_source[--[[---@not nil]] source] or source,
                    required_rank = item.skill,
                    is_reagent = is_reagent,
                    difficulty = player_db.profession_to_skill_to_difficulty[localized_profession_name][localized_item_name],
                    other_character_to_difficulty = other_character_to_difficulty,
                }
                tinsert(group_items, tooltip_item)
            end

            tinsert(item_groups, {
                localized_profession_name = localized_profession_name,
                my_profession_rank = (my_profession_localized_name_to_rank[localized_profession_name] or {}).rank,
                items = group_items
            })
        end
    end

    return item_groups
end

---@param groups TooltipItemGroup[]
---@return TooltipItemGroup[]
function MasterTradeSkills:FilterTooltipItemGroups(groups)
    local player_db = self.db:GetOrCreatePlayer()

    local difficulty_options = self.db_options.ShowSkillsByDifficulty
    ---@type table<string, boolean>
    local difficulty_to_option = {
        ["trivial"] = difficulty_options.Trivial,
        ["easy"] = difficulty_options.Easy,
        ["medium"] = difficulty_options.Medium,
        ["optimal"] = difficulty_options.Optimal,
        ["difficult"] = difficulty_options.Difficult,
    }

    local new_groups = {}
    for _, group in ipairs(groups) do
        local new_items = {}
        for _, item in ipairs(group.items) do
            local difficulty = player_db.profession_to_skill_to_difficulty[group.localized_profession_name][item.localized_name]
            local show_by_difficulty = difficulty == nil or difficulty_to_option[difficulty or ""]
            local show_by_learned = difficulty ~= nil and self.db_options.ShowSkillsByStatus.Learned
                or difficulty == nil and self.db_options.ShowSkillsByStatus.NotLearned
            if show_by_difficulty and show_by_learned then
                tinsert(new_items, item)
            end
        end
        if getn(new_items) > 0 then
            group.items = new_items
            tinsert(new_groups, group)
        end
    end

    return new_groups
end

---@param groups TooltipItemGroup[]
function MasterTradeSkills:SortTooltipItemGroups(groups)
    table.sort(groups, function(a, b)
        local a_rank = a.my_profession_rank or 0
        local b_rank = b.my_profession_rank or 0
        if a_rank ~= b_rank and (a_rank == 0 or b_rank == 0) then
            return a_rank > b_rank
        end
        return a.localized_profession_name < b.localized_profession_name
    end)

    for _, group in ipairs(groups) do
        table.sort(group.items, function(a, b)
            if self.db_options.SortingOptions.NotLearnedSkillsLast then
                local a_learned = a.difficulty ~= nil
                local b_learned = b.difficulty ~= nil
                if a_learned ~= b_learned then
                    return a_learned
                end
            end

            if a.required_rank ~= b.required_rank then
                if self.db_options.SortingOptions.HigherLevelSkillsFirst then
                    return a.required_rank > b.required_rank
                else
                    return a.required_rank < b.required_rank
                end
            end

            return a.localized_name < b.localized_name
        end)
    end
end

---@param groups TooltipItemGroup[]
---@return TooltipItemGroup[]
function MasterTradeSkills:LimitTooltipItemGroups(groups)
    local item_count_total = 0
    ---@type number[]
    local item_count_by_groups = {}
    for _, group in ipairs(groups) do
        local n = getn(group.items)
        tinsert(item_count_by_groups, n)
        item_count_total = item_count_total + n
    end

    local item_count_limit = self.db_options.HowManySkillsToShow
    if item_count_total <= item_count_limit then
        return groups
    end

    local new_item_count_total = 0
    local new_groups = {}
    for i, group in ipairs(groups) do
        local group_weight = item_count_by_groups[i] / item_count_total
        local group_size = ceil(group_weight * item_count_limit)
        local new_items = {}
        for j, item in ipairs(group.items) do
            if j <= group_size and new_item_count_total < item_count_limit then
                tinsert(new_items, item)
                new_item_count_total = new_item_count_total + 1
            end
        end
        group.items = new_items
        if getn(group.items) > 0 then
            tinsert(new_groups, group)
        end
    end

    return new_groups
end

---@param tooltip_frame GameTooltip
---@param groups TooltipItemGroup[]
function MasterTradeSkills:DrawTooltipItemGroups(tooltip_frame, groups)
    ---@type table<string, string>
    local difficulty_to_color = {
        ["trivial"] = "|cFFA0A0A0",
        ["easy"] = "|cFF40C040",
        ["medium"] = "|cFFFFEE00",
        ["optimal"] = "|cFFFF9900",
        ["difficult"] = "|cFFFF0000",
    }

    for _, group in ipairs(groups) do
        local my_rank = group.my_profession_rank or 0
        local my_rank_text = my_rank > 0 and format(" (%d)", my_rank) or ""

        local prof_color = "|cFF00FF11"
        local prof_text_left = format("%s%s|r", prof_color, L.txt_recipes)
        local prof_text_right = format("%s%s%s|r", prof_color, group.localized_profession_name, my_rank_text)
        tooltip_frame:AddDoubleLine(prof_text_left, prof_text_right)

        local source_color = "|cFF56B59D"
        for _, item in ipairs(group.items) do
            local other_characters_text = ""
            if self.db_options.ShowAltName then
                for character, difficulty in pairs(item.other_character_to_difficulty) do
                    local indent = other_characters_text == "" and "" or "  "
                    other_characters_text = other_characters_text .. indent .. format("%s[%s]|r", difficulty_to_color[difficulty], character)
                end
            end

            local skill_color = difficulty_to_color[item.difficulty or "difficult"]

            local item_text_left = format("|cFFFFB444 %s|r%s%s|r",
                item.is_reagent and '+' or '-',
                skill_color,
                item.localized_name)

            local item_text_right = ""
            if other_characters_text ~= "" then
                item_text_right = other_characters_text
            else
                item_text_right = format("%s%s|r %s(%d)|r",
                    source_color,
                    item.localized_source,
                    skill_color,
                    item.required_rank)
            end

            tooltip_frame:AddDoubleLine(item_text_left, item_text_right)
        end
    end
end

function MasterTradeSkills:Print(text)
    DEFAULT_CHAT_FRAME:AddMessage(text, 0.0, 1.0, 0.0);
end
