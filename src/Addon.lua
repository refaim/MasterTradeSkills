setfenv(1, MasterTradeSkills)

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "Cannot find instance of a LibStub")

local AceAddon, _ = LibStub("AceAddon-3.0")

---@type AceAddonDef
---@field db MasterTradeSkills_Database
---@field options MasterTradeSkillsDBOptions
---@field english_crafting_profession_name_to_localized table<string, string>
local MasterTradeSkills = AceAddon:NewAddon(MtsAddonName, "AceConfig-3.0", "AceHook-3.0")

local AceDB, _ = LibStub("AceDB-3.0")

local AceLocale, _ = LibStub("AceLocale-3.0")
local L = --[[---@type MasterTradeSkillsLocale]] AceLocale:GetLocale(MtsAddonName, false)

local LibCraftingProfessions = --[[---@type LibCraftingProfessions]] LibStub("LibCraftingProfessions-1.0")
local LibCrafts = --[[---@type LibCrafts]] LibStub("LibCrafts-1.0")
local LibItemTooltip = --[[---@type LibItemTooltip]] LibStub("LibItemTooltip-1.0")

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

    LibCraftingProfessions:RegisterEvent("LCP_SKILLS_UPDATE", function(profession, skills)
        self.db:SavePlayerSkills(profession, skills)
    end)

    LibItemTooltip:RegisterEvent("OnShow", function(tooltip, item_link, item_id)
        self:OnItemTooltipShow(tooltip, item_link, item_id)
    end)
end

---@return void
function MasterTradeSkills:OnEnable()
    ---@type table<string, string>
    local english_crafting_profession_name_to_localized = {}
    for _, profession in ipairs(LibCraftingProfessions:GetSupportedProfessions()) do
        english_crafting_profession_name_to_localized[profession.english_name] = profession.localized_name
    end
    self.english_crafting_profession_name_to_localized = english_crafting_profession_name_to_localized

    self:Print(L.txt_addon_loaded);
end

---@param tooltip GameTooltip
---@param item_link string
---@param item_id number
function MasterTradeSkills:OnItemTooltipShow(tooltip, item_link, item_id)
    local enhance = self.db_options.EnhanceTooltips
    if tooltip == GameTooltip then
        enhance = enhance and (IsShiftKeyDown() == 1 or not self.db_options.EnhanceTooltipsOnlyWhileShiftIsPressed)
    end
    if enhance and self:EnhanceTooltip(tooltip, item_id) then
        tooltip:Show()
    end
end

---@shape TooltipItemGroup
---@field localized_profession_name string
---@field my_profession_rank number|nil
---@field items TooltipItem[]

---@shape TooltipItem
---@field localized_name string
---@field localized_sources string[]
---@field required_rank number
---@field is_reagent boolean
---@field difficulty string|nil
---@field other_character_to_difficulty table<string, string>

---@param tooltip GameTooltip
---@param item_id number
---@return boolean
function MasterTradeSkills:EnhanceTooltip(tooltip, item_id)
    local groups = self:CreateTooltipItemGroups(item_id)
    groups = self:FilterTooltipItemGroups(groups)
    self:SortTooltipItemGroups(groups)
    groups = self:LimitTooltipItemGroups(groups)
    if getn(groups) == 0 then
        return false
    end
    self:DrawTooltipItemGroups(tooltip, groups)
    return true
end

---@param reagent_id number
---@return TooltipItemGroup[]
function MasterTradeSkills:CreateTooltipItemGroups(reagent_id)
    ---@type table<LcSpellSource|LcRecipeSource, string>
    local source_enum_to_string = {
        [LibCrafts.constants.spell_sources.LearnedAutomatically] = L.txt_source_trainer,
        [LibCrafts.constants.spell_sources.Quest] = L.txt_source_quest,
        [LibCrafts.constants.spell_sources.Trainer] = L.txt_source_trainer,
        [LibCrafts.constants.spell_sources.WorldObject] = L.txt_source_world_object,
        [LibCrafts.constants.recipe_sources.Chest] = L.txt_source_chest,
        [LibCrafts.constants.recipe_sources.CraftedByEngineer] = L.txt_source_craft,
        [LibCrafts.constants.recipe_sources.Drop] = L.txt_source_drop,
        [LibCrafts.constants.recipe_sources.Fishing] = L.txt_source_fishing,
        [LibCrafts.constants.recipe_sources.GiftedToReturningEngineers] = L.txt_source_gift,
        [LibCrafts.constants.recipe_sources.Pickpocketing] = L.txt_source_pickpocketing,
        [LibCrafts.constants.recipe_sources.Quest] = L.txt_source_quest,
        [LibCrafts.constants.recipe_sources.Vendor] = L.txt_source_vendor,
    }

    ---@type table<string, {rank: number|nil}>
    local my_profession_localized_name_to_rank = {}
    for _, profession in ipairs(LibCraftingProfessions:GetPlayerProfessions() or {}) do
        my_profession_localized_name_to_rank[profession.localized_name] = {["rank"] = profession.cur_rank}
    end

    ---@type table<string, LcCraft[]>
    local localized_profession_to_crafts = {}
    for _, craft in ipairs(LibCrafts:GetCraftsByReagentId(reagent_id)) do
        local localized_profession_name = self.english_crafting_profession_name_to_localized[craft.en_profession_name]
        local is_profession_enabled_in_tooltips = self.db_options.ShowSkillsByTradeSkill[localized_profession_name]
        if is_profession_enabled_in_tooltips then
            local crafts = localized_profession_to_crafts[localized_profession_name]
            if crafts == nil then
                crafts = {}
                localized_profession_to_crafts[localized_profession_name] = crafts
            end
            tinsert(crafts, craft)
        end
    end

    local player_db = self.db:GetOrCreatePlayer()
    ---@type TooltipItemGroup[]
    local item_groups = {}
    for localized_profession_name, crafts in pairs(localized_profession_to_crafts) do
        ---@type TooltipItem[]
        local group_items = {}

        for _, craft in ipairs(crafts) do
            ---@type table<string, boolean>
            local localized_sources_set = {}
            for _, spell_source in ipairs(craft.sources) do
                localized_sources_set[source_enum_to_string[spell_source]] = true
            end
            for _, recipe in ipairs(craft.recipes) do
                for _, recipe_source in ipairs(recipe.sources) do
                    localized_sources_set[source_enum_to_string[recipe_source]] = true
                end
            end
            local localized_sources = {}
            for localized_source, _ in pairs(localized_sources_set) do
                tinsert(localized_sources, localized_source)
            end

            ---@type table<string, string>
            local other_character_to_difficulty = {}
            for _, character in ipairs(self.db:GetOtherCharactersFromCurrentRealm()) do
                other_character_to_difficulty[character.name] = character.profession_to_skill_to_difficulty[localized_profession_name][craft.localized_spell_name]
            end

            local is_reagent = false
            if craft.result ~= nil then
                local result_item_id = (--[[---@not nil]] craft.result).id
                is_reagent = next(LibCrafts:GetCraftsByReagentId(result_item_id)) ~= nil
            end

            ---@type TooltipItem
            local tooltip_item = {
                localized_name = craft.localized_spell_name,
                localized_sources = localized_sources,
                required_rank = craft.skill_level,
                is_reagent = is_reagent,
                difficulty = player_db.profession_to_skill_to_difficulty[localized_profession_name][craft.localized_spell_name],
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

            local source_text = ""
            local sources_num = getn(item.localized_sources)
            table.sort(item.localized_sources)
            for i, source in ipairs(item.localized_sources) do
                source_text = source_text .. source .. (i < sources_num and ", " or "")
            end

            local item_text_right = ""
            if other_characters_text ~= "" then
                item_text_right = other_characters_text
            else
                item_text_right = format("%s%s|r %s(%d)|r",
                    source_color,
                    source_text,
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
