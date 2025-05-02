--[[
    Name: LibCraftingProfessions-1.0
    Developed by: Refaim (rkharito@yandex.ru, https://github.com/refaim/)
    Website: https://github.com/refaim/LibCraftingProfessions-1.0
    Description: A library designed to provide a universal interface for crafting professions.
    Dependencies: LibStub
    Compatibility: World of Warcraft Vanilla (1.12.1)
]]

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil)

local untyped_lib, _ = LibStub:NewLibrary("LibCraftingProfessions-1.0", 2)
if not untyped_lib then
    return
end

---@class LibCraftingProfessions
---@field event_to_handlers table<string, function[]>
---@field event_frame Frame

local lib = --[[---@type LibCraftingProfessions]] untyped_lib
if lib.event_to_handlers == nil then
    lib.event_to_handlers = {}
end

---@type table<string, boolean>
local ALL_EXISTING_CRAFTING_PROFESSIONS_SET = {
    ["Alchemy"] = true,
    ["Blacksmithing"] = true,
    ["Cooking"] = true,
    ["Enchanting"] = true,
    ["Engineering"] = true,
    ["First Aid"] = true,
    ["Leatherworking"] = true,
    ["Mining"] = true,
    ["Poisons"] = true,
    ["Tailoring"] = true,
    ["Jewelcrafting"] = true
}

---@type table<string, string>
local ENGLISH_TO_LOCALIZED = {}
---@type table<string, string>
local LOCALIZED_TO_ENGLISH = {}

---@shape LcpProfession
---@field english_name string
---@field localized_name string

---@shape LcpKnownProfession: LcpProfession
---@field cur_rank number|nil

---@alias LcpSkillDifficulty "trivial" | "easy" | "medium" | "optimal" | "difficult"

---@shape LcpKnownSkill
---@field localized_name string
---@field item_link string
---@field difficulty LcpSkillDifficulty
---@field num_available number

---@alias LcpScanSkillsHandler fun(profession: LcpKnownProfession, skills: LcpKnownSkill[]):void

---@type table<string, LcpKnownSkill[]>
local skills_by_english_profession_name = {}

---@return boolean
local function ready(value)
    if value == nil then
        return false
    end
    if type(value) == "table" then
        return next(value) ~= nil
    end
    return value ~= "" and value ~= 0
end

---
--- Retrieves a list of all supported crafting professions in the game.
---
---@return LcpProfession[]
function lib:GetSupportedProfessions()
    ---@type LcpProfession[]
    local professions = {}
    for english_name, _ in pairs(ALL_EXISTING_CRAFTING_PROFESSIONS_SET) do
        tinsert(professions, {english_name = english_name, localized_name = ENGLISH_TO_LOCALIZED[english_name]})
    end
    return professions
end

---
--- Retrieves a list of the player's known crafting professions.
--- Returns a table of known professions, or nil if game data is not yet available.
--- Use RegisterEvent("LCP_SKILLS_UPDATE", ...) to ensure data availability.
---
---@return LcpKnownProfession[]|nil
function lib:GetPlayerProfessions()
    local num_of_professions = GetNumSkillLines()
    if not ready(num_of_professions) then
        return nil
    end

    ---@type LcpKnownProfession[]
    local professions = {}
    for i = 1, num_of_professions do
        local localized_name, is_header, _, rank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if not is_header then
            if not ready(localized_name) then
                return nil
            end

            local english_name = LOCALIZED_TO_ENGLISH[localized_name]
            local is_crafting_profession = ALL_EXISTING_CRAFTING_PROFESSIONS_SET[english_name] ~= nil
            if is_crafting_profession then
                local has_rank = english_name ~= "Poisons"
                if has_rank and not ready(rank) then
                    return nil
                end
                tinsert(professions, {english_name = english_name, localized_name = localized_name, cur_rank = rank})
            end
        end
    end

    return professions
end

---
--- Retrieves a list of the player's skills for a specific profession.
--- Returns a table of known skills for the specified profession, or nil if game data is not yet available
--- Use RegisterEvent("LCP_SKILLS_UPDATE", ...) to ensure data availability.
---
--- @param profession_name string
--- @return LcpKnownSkill[]|nil
function lib:GetPlayerProfessionSkills(profession_name)
    return skills_by_english_profession_name[profession_name] or skills_by_english_profession_name[LOCALIZED_TO_ENGLISH[profession_name]]
end

---
--- Registers a handler for the specific library event.
---
---@param event "LCP_SKILLS_UPDATE" @ The event to register for. This event is fired when skill data is updated and ready.
---@param handler fun(profession: LcpKnownProfession, skills: LcpKnownSkill[]):void @ The function to call when the event is triggered.
function lib:RegisterEvent(event, handler)
    if lib.event_to_handlers[event] == nil then
        lib.event_to_handlers[event] = {}
    end
    tinsert(lib.event_to_handlers[event], --[[---@type function]] handler)
end

---@shape _LcpTradeSkillFilterOption
---@field name string
---@field type "inv_slot" | "subclass"

---@shape _LcpProfessionAdapter
---@field GetProfessionInfo fun():string|nil, number|nil, number|nil
---@field GetNumSkills fun():number|nil
---@field GetSkillInfo fun(index:number):string|nil, string|nil, number|nil, wowboolean
---@field GetSkillItemLink fun(index:number):string|nil
---@field ExpandHeader fun(index:number):void
---@field CollapseHeader fun(index:number):void
---@field DisableFilters fun():void

---@param adapter _LcpProfessionAdapter
---@return LcpKnownSkill[]|nil
local function scan_skills(adapter)
    local profession, cur_rank, max_rank = adapter.GetProfessionInfo()
    if not ready(profession) or not ready(cur_rank) or not ready(max_rank) then
        return nil
    end

    adapter:DisableFilters()

    local num_of_skills_before_expansion = adapter.GetNumSkills()
    if not ready(num_of_skills_before_expansion) then
        return nil
    end

    ---@type table<string, true>
    local set_of_headers_to_collapse = {}
    for i = 1, num_of_skills_before_expansion do
        local skill_name, skill_type_or_difficulty, _, is_expanded = adapter.GetSkillInfo(i)
        if not ready(skill_name) or not ready(skill_type_or_difficulty) then
            return nil
        end
        if skill_type_or_difficulty == "header" and is_expanded == nil then
            set_of_headers_to_collapse[ --[[---@not nil]] skill_name] = true
        end
    end
    adapter.ExpandHeader(0)

    local num_of_skills_after_expansion = adapter.GetNumSkills()
    if not ready(num_of_skills_after_expansion) then
        return nil
    end

    ---@type LcpKnownSkill[]
    local skills = {}
    for i = 1, num_of_skills_after_expansion do
        local skill_name, skill_type_or_difficulty, num_available, _ = adapter.GetSkillInfo(i)
        if not ready(skill_name) or not ready(skill_type_or_difficulty) then
            return nil
        end
        if skill_type_or_difficulty ~= "header" then
            local item_link = adapter.GetSkillItemLink(i)
            if num_available == nil or not ready(item_link) then
                return nil
            end

            ---@type LcpKnownSkill
            local skill = {
                localized_name = --[[---@not nil]] skill_name,
                item_link = --[[---@not nil]] item_link,
                difficulty = --[[---@type LcpSkillDifficulty]] skill_type_or_difficulty,
                num_available = --[[---@not nil]] num_available,
            }
            tinsert(skills, skill)
        end
    end

    for i = adapter.GetNumSkills(), 1, -1 do
        local skill_name, skill_type_or_difficulty, _, _ = adapter.GetSkillInfo(i)
        if skill_type_or_difficulty == "header" and set_of_headers_to_collapse[ --[[---@not nil]] skill_name] ~= nil then
            adapter.CollapseHeader(i)
        end
    end

    return skills
end

---@param known_professions LcpKnownProfession[]|nil
local function forget_obsolete_professions(known_professions)
    if known_professions == nil then
        return
    end

    ---@type table<string, boolean>
    local known_profession_names_set = {}
    for _, profession in ipairs(--[[---@not nil]] known_professions) do
        known_profession_names_set[profession.english_name] = true
    end

    for english_name, _ in pairs(skills_by_english_profession_name) do
        if known_profession_names_set[english_name] == nil then
            skills_by_english_profession_name[english_name] = nil
        end
    end
end

---@param english_name string
---@param skills LcpKnownSkill[]
local function save_skills(english_name, skills)
    skills_by_english_profession_name[english_name] = skills

    local known_professions = lib:GetPlayerProfessions()
    forget_obsolete_professions(known_professions)

    local profession
    for _, candidate in ipairs(known_professions or {}) do
        if candidate.english_name == english_name then
            profession = candidate
            break
        end
    end
    if profession == nil then
        return
    end

    for _, handler in ipairs(lib.event_to_handlers["LCP_SKILLS_UPDATE"] or {}) do
        handler(profession, skills)
    end
end

local function scan_craft_frame()
    ---@type _LcpProfessionAdapter
    local adapter = {
        GetProfessionInfo = function()
            local name, cur_rank, max_rank = GetCraftDisplaySkillLine()
            if name == nil then -- GetCraftDisplaySkillLine() returns nil for the "Beast Training" frame
                name = GetCraftName()
            end
            return name, cur_rank, max_rank
        end,
        GetNumSkills = GetNumCrafts,
        GetSkillInfo = function(i)
            local name, _, type, num_available, is_expanded = GetCraftInfo(i)
            return name, type, num_available, is_expanded
        end,
        GetSkillItemLink = GetCraftItemLink,
        ExpandHeader = ExpandCraftSkillLine,
        CollapseHeader = CollapseCraftSkillLine,
        DisableFilters = function() end,
    }

    local localized_name, _, _ = adapter.GetProfessionInfo()
    if not ready(localized_name) then
        return
    end

    local english_name = LOCALIZED_TO_ENGLISH[--[[---@not nil]] localized_name]
    if english_name == nil or english_name == "Beast Training" then
        return
    end

    local skills = scan_skills(adapter)
    if not ready(skills) then
        return
    end

    save_skills(english_name, --[[---@not nil]] skills)
end

---@shape _LcpSkillFilterAdapter
---@field GetType fun(): "inv_slot" | "subclass"
---@field GetOptions fun(): string...
---@field GetOptionState fun(index:number): wowboolean
---@field SetOptionState fun(index:number, enable:wowboolean, exclusive:wowboolean): void

---@param adapter _LcpSkillFilterAdapter
---@return _LcpTradeSkillFilterOption[]
local function disable_trade_skill_filters(adapter)
    if adapter.GetOptionState(0) == 1 then
        return {}
    end

    ---@type _LcpTradeSkillFilterOption[]
    local selected_options = {}
    for i, option in ipairs({adapter.GetOptions()}) do
        if adapter.GetOptionState(i) == 1 then
            tinsert(selected_options, {name = option, type = adapter.GetType()})
        end
    end

    adapter.SetOptionState(0, 1, 1)

    return selected_options
end

local function scan_trade_skill_frame()
    ---@type _LcpSkillFilterAdapter
    local inv_slot_filter_adapter = {
        GetType = function() return "inv_slot" end,
        GetOptions = GetTradeSkillInvSlots,
        GetOptionState = GetTradeSkillInvSlotFilter,
        SetOptionState = SetTradeSkillInvSlotFilter,
    }

    ---@type _LcpSkillFilterAdapter
    local subclass_filter_adapter = {
        GetType = function() return "subclass" end,
        GetOptions = GetTradeSkillSubClasses,
        GetOptionState = GetTradeSkillSubClassFilter,
        SetOptionState = SetTradeSkillSubClassFilter,
    }

    ---@type _LcpProfessionAdapter
    local profession_adapter = {
        GetProfessionInfo = GetTradeSkillLine,
        GetNumSkills = GetNumTradeSkills,
        GetSkillInfo = GetTradeSkillInfo,
        GetSkillItemLink = GetTradeSkillItemLink,
        ExpandHeader = ExpandTradeSkillSubClass,
        CollapseHeader = CollapseTradeSkillSubClass,
        DisableFilters = function()
            for _, adapter in ipairs({inv_slot_filter_adapter, subclass_filter_adapter}) do
                disable_trade_skill_filters(adapter)
            end
        end,
    }

    local localized_name, _, _ = profession_adapter.GetProfessionInfo()
    if not ready(localized_name) then
        return
    end

    local english_name = LOCALIZED_TO_ENGLISH[--[[---@not nil]] localized_name]
    if english_name == nil then
        return
    end

    local skills = scan_skills(profession_adapter)
    if not ready(skills) then
        return
    end

    save_skills(english_name, --[[---@not nil]] skills)
end

local L = ENGLISH_TO_LOCALIZED
local game_locale = GetLocale()
if game_locale == "enUS" or game_locale == "enGB" then
    L["Alchemy"] = "Alchemy"
    L["Beast Training"] = "Beast Training"
    L["Blacksmithing"] = "Blacksmithing"
    L["Cooking"] = "Cooking"
    L["Enchanting"] = "Enchanting"
    L["Engineering"] = "Engineering"
    L["First Aid"] = "First Aid"
    L["Leatherworking"] = "Leatherworking"
    L["Mining"] = "Mining"
    L["Poisons"] = "Poisons"
    L["Tailoring"] = "Tailoring"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "deDE" then
    L["Alchemy"] = "Alchimie"
    L["Beast Training"] = "Wildtierausbildung"
    L["Blacksmithing"] = "Schmiedekunst"
    L["Cooking"] = "Kochkunst"
    L["Enchanting"] = "Verzauberkunst"
    L["Engineering"] = "Ingenieurskunst"
    L["First Aid"] = "Erste Hilfe"
    L["Leatherworking"] = "Lederverarbeitung"
    L["Mining"] = "Bergbau"
    L["Poisons"] = "Gifte"
    L["Tailoring"] = "Schneiderei"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "esES" then
    L["Alchemy"] = "Alquimia"
    L["Beast Training"] = "Doma de bestias"
    L["Blacksmithing"] = "Herrería"
    L["Cooking"] = "Cocina"
    L["Enchanting"] = "Encantamiento"
    L["Engineering"] = "Ingeniería"
    L["First Aid"] = "Primeros auxilios"
    L["Leatherworking"] = "Peletería"
    L["Mining"] = "Minería"
    L["Poisons"] = "Venenos"
    L["Tailoring"] = "Costura"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "frFR" then
    L["Alchemy"] = "Alchimie"
    L["Beast Training"] = "Apprivoisement"
    L["Blacksmithing"] = "Forge"
    L["Cooking"] = "Cuisine"
    L["Enchanting"] = "Enchantement"
    L["Engineering"] = "Ingénierie"
    L["First Aid"] = "Secourisme"
    L["Leatherworking"] = "Travail du cuir"
    L["Mining"] = "Minage"
    L["Poisons"] = "Poisons"
    L["Tailoring"] = "Couture"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "koKR" then
    L["Alchemy"] = "연금술"
    L["Beast Training"] = "야수 조련"
    L["Blacksmithing"] = "대장기술"
    L["Cooking"] = "요리"
    L["Enchanting"] = "마법부여"
    L["Engineering"] = "기계공학"
    L["First Aid"] = "응급치료"
    L["Leatherworking"] = "가죽 세공"
    L["Mining"] = "채광"
    L["Poisons"] = "독"
    L["Tailoring"] = "재봉술"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "ruRU" then
    L["Alchemy"] = "Алхимия"
    L["Beast Training"] = "Дрессировка"
    L["Blacksmithing"] = "Кузнечное дело"
    L["Cooking"] = "Кулинария"
    L["Enchanting"] = "Наложение чар"
    L["Engineering"] = "Инженерное дело"
    L["First Aid"] = "Первая помощь"
    L["Leatherworking"] = "Кожевничество"
    L["Mining"] = "Горное дело"
    L["Poisons"] = "Яды"
    L["Tailoring"] = "Портняжное дело"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "zhCN" then
    L["Alchemy"] = "炼金术"
    L["Beast Training"] = "训练野兽"
    L["Blacksmithing"] = "锻造"
    L["Cooking"] = "烹饪"
    L["Enchanting"] = "附魔"
    L["Engineering"] = "工程学"
    L["First Aid"] = "急救"
    L["Leatherworking"] = "制皮"
    L["Mining"] = "采矿"
    L["Poisons"] = "毒药"
    L["Tailoring"] = "裁缝"
    L["Jewelcrafting"] = "Jewelcrafting"
elseif game_locale == "zhTW" then
    L["Alchemy"] = "煉金術"
    L["Beast Training"] = "訓練野獸"
    L["Blacksmithing"] = "鍛造"
    L["Cooking"] = "烹飪"
    L["Enchanting"] = "附魔"
    L["Engineering"] = "工程學"
    L["First Aid"] = "急救"
    L["Leatherworking"] = "製皮"
    L["Mining"] = "採礦"
    L["Poisons"] = "毒藥"
    L["Tailoring"] = "裁縫"
    L["Jewelcrafting"] = "Jewelcrafting"
end

for english_name, localized_name in pairs(ENGLISH_TO_LOCALIZED) do
    LOCALIZED_TO_ENGLISH[localized_name] = english_name
end

if lib.event_frame ~= nil then
    lib.event_frame:UnregisterAllEvents()
    lib.event_frame:SetScript("OnEvent", nil)
end
lib.event_frame = CreateFrame("Frame")
lib.event_frame:SetScript("OnEvent", function()
    if event == "CRAFT_SHOW" then
        scan_craft_frame()
    elseif event == "TRADE_SKILL_SHOW" then
        scan_trade_skill_frame()
    end
end)
lib.event_frame:RegisterEvent("CRAFT_SHOW")
lib.event_frame:RegisterEvent("TRADE_SKILL_SHOW")
