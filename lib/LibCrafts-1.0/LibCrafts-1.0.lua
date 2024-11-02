--[[
    Name: LibCrafts-1.0
    Developed by: Refaim (rkharito@yandex.ru, https://github.com/refaim/)
    Website: https://github.com/refaim/LibCrafts-1.0
    Description: A library designed to provide a database crafting spells, recipes, reagents etc.
    Dependencies: LibStub
    Compatibility: World of Warcraft Vanilla (1.12.1)
]]

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil)

local untyped_lib, _ = LibStub:NewLibrary("LibCrafts-1.0", 2)
if not untyped_lib then return end

local lib = --[[---@type LibCrafts]] untyped_lib
if lib.modules_by_name == nil then
    lib.modules_by_name = {}
end

lib.env = {
    is_debug = false,
    is_turtle_wow = TargetHPText ~= nil and TargetHPPercText ~= nil,
}

lib.constants = {
    qualities = {
        Poor = 101,
        Common = 102,
        Uncommon = 103,
        Rare = 104,
        Epic = 105,
        Legendary = 106,
    },
    spell_sources = {
        LearnedAutomatically = 201,
        Quest = 202,
        Trainer = 203,
        WorldObject = 204,
    },
    recipe_sources = {
        Chest = 301,
        CraftedByEngineer = 302,
        Drop = 303,
        Fishing = 304,
        GiftedToReturningEngineers = 305,
        Pickpocketing = 306,
        Quest = 307,
        Vendor = 308,
    },
}

---@class LibCrafts
---@field env LcEnvironment
---@field constants LcConstants
---@field modules_by_name table<string, LcModule>

---@shape LcEnvironment
---@field is_debug boolean
---@field is_turtle_wow boolean

---@shape LcConstants
---@field qualities LcItemQualities
---@field spell_sources LcSpellSources
---@field recipe_sources LcRecipeSources

---@shape LcItemQualities
---@field Poor 101
---@field Common 102
---@field Uncommon 103
---@field Rare 104
---@field Epic 105
---@field Legendary 106

---@alias LcItemQuality 101 | 102 | 103 | 104 | 105 | 106

---@shape LcSpellSources
---@field LearnedAutomatically 201
---@field Quest 202
---@field Trainer 203
---@field WorldObject 204

---@alias LcSpellSource 201 | 202 | 203 | 204

---@shape LcRecipeSources
---@field Chest 301
---@field CraftedByEngineer 302
---@field Drop 303
---@field Fishing 304
---@field GiftedToReturningEngineers 305
---@field Pickpocketing 306
---@field Quest 307
---@field Vendor 308

---@alias LcRecipeSource 301 | 302 | 303 | 304 | 305 | 306 | 307 | 308

---@shape LcItem
---@field id number

---@shape LcRecipe: LcItem
---@field quality LcItemQuality
---@field sources LcRecipeSource[]

---@class LcCraft
---@field en_profession_name string
---@field spell_id number
---@field localized_spell_name string
---@field skill_level number
---@field result LcItem|nil
---@field sources LcSpellSource[]
---@field recipes LcRecipe[]
---@field reagent_id_to_count table<number, number>
local Craft = {}

---@type table<number, LcCraft>
local spell_id_to_craft = {}
---@type table<number, number[]>
local reagent_id_to_spell_ids = {}

---
--- Returns a list of crafts by reagent item id.
---
---@param item_id number
---@return LcCraft[]
function lib:GetCraftsByReagentId(item_id)
    local crafts = {}
    for _, spell_id in ipairs(reagent_id_to_spell_ids[item_id] or {}) do
        tinsert(crafts, spell_id_to_craft[spell_id])
    end
    return crafts
end

---@class LcModule
---@field name string
---@field version number

---@class LcProfessionModule: LcModule
---@field en_profession_name string
local ProfessionModule = {}

---@class LcLocaleModule: LcModule
---@field en_to_any table<string, string|boolean>
local LocaleModule = {}

---@return table<string, string|boolean>
function LocaleModule:GetStrings()
    return self.en_to_any
end

---@param name string
---@param version number
---@return boolean
local function module_registered(name, version)
    local current_version = (lib.modules_by_name[name] or {}).version
    if current_version ~= nil and current_version >= version then
        return true
    end
    return false
end

---@param name string
---@param version number
---@param profession string
---@return LcProfessionModule|nil
function lib:RegisterProfessionModule(name, version, profession)
    if self.env.is_debug then
        assert(type(name) == "string" and name ~= "")
        assert(type(version) == "number" and version > 0)
        assert(type(profession) == "string" and profession ~= "")
    end

    if module_registered(name, version) then
        return nil
    end

    local object = {name = name, version = version, en_profession_name = profession}
    setmetatable(object, {__index = ProfessionModule})

    local module = --[[---@type LcProfessionModule]] object
    self.modules_by_name[name] = module
    return module
end

---@param name string
---@param locale string
---@param version number
---@return LcLocaleModule|nil
function lib:RegisterLocaleModule(name, locale, version)
    if self.env.is_debug then
        assert(type(name) == "string" and locale ~= "")
        assert(type(locale) == "string" and locale ~= "")
        assert(type(version) == "number" and version > 0)
    end

    if locale == "enGB" then
        locale = "enUS"
    end

    if locale ~= GetLocale() or module_registered(name, version) then
        return nil
    end

    local object = {name = name, version = version, en_to_any = {}}
    setmetatable(object, {__index = LocaleModule})

    local module = --[[---@type LcLocaleModule]] object
    self.modules_by_name[name] = module
    return module
end

---@type table<number, boolean>
local SPELL_SOURCE_SET = {}
for _, source in pairs(lib.constants.spell_sources) do
    SPELL_SOURCE_SET[source] = true
end

---@param spell_id number
---@param spell_name string
---@param skill_level number
---@param sources LcSpellSource[]
---@return LcCraft
function ProfessionModule:NewCraft(spell_id, spell_name, skill_level, sources)
    if lib.env.is_debug then
        assert(type(spell_id) == "number" and spell_id > 0)
        assert(type(spell_name) == "string" and spell_name ~= "")
        assert(type(skill_level) == "number" and skill_level > 0)
        assert(type(sources) == "table")
        for _, source in ipairs(sources) do
            assert(type(source) == "number" and SPELL_SOURCE_SET[source] ~= nil)
        end
    end

    local locale_module = --[[---@type LcLocaleModule]] lib.modules_by_name["Locales-Spells"]
    ---@type table<string, string|boolean>
    local L = {}
    if locale_module ~= nil then
        L = locale_module:GetStrings()
    end

    local localized_spell_name = L[spell_name]
    if type(localized_spell_name) ~= "string" or localized_spell_name == "" then
        localized_spell_name = spell_name
    end

    local object = {
        en_profession_name = self.en_profession_name,
        spell_id = spell_id,
        localized_spell_name = localized_spell_name,
        skill_level = skill_level,
        sources = sources,
        recipes = {},
        reagent_id_to_count = {},
    }
    setmetatable(object, {__index = Craft})
    return --[[---@type LcCraft]] object
end

---@type table<number, boolean>
local ITEM_QUALITY_SET = {}
for _, quality in pairs(lib.constants.qualities) do
    ITEM_QUALITY_SET[quality] = true
end

---@type table<number, boolean>
local RECIPE_SOURCE_SET = {}
for _, source in pairs(lib.constants.recipe_sources) do
    RECIPE_SOURCE_SET[source] = true
end

---@param id number
---@param quality LcItemQuality
---@param sources LcRecipeSource[]
---@return self
function Craft:AddRecipe(id, quality, sources)
    if lib.env.is_debug then
        assert(type(id) == "number" and id > 0)
        assert(type(quality) == "number" and ITEM_QUALITY_SET[quality] ~= nil)
        assert(type(sources) == "table" and getn(sources) > 0)
        for _, source in ipairs(sources) do
            assert(type(source) == "number" and RECIPE_SOURCE_SET[source] ~= nil)
        end
        for _, recipe in ipairs(self.recipes) do
            assert(recipe.id ~= id)
        end
    end

    tinsert(self.recipes, {id = id, quality = quality, sources = sources})

    return self
end

---@param item_id number
---@return self
function Craft:SetResult(item_id)
    if lib.env.is_debug then
        assert(type(item_id) == "number" and item_id > 0)
        assert(self.result == nil)
    end

    self.result = {id = item_id }

    return self
end

---@param id number
---@param count number
---@return self
function Craft:AddReagent(id, count)
    if lib.env.is_debug then
        assert(type(id) == "number" and id > 0)
        assert(type(count) == "number" and count > 0)
        assert(self.reagent_id_to_count[id] == nil)
    end

    self.reagent_id_to_count[id] = count

    return self
end

function Craft:Save()
    if lib.env.is_debug then
        assert(next(self.sources) ~= nil or next(self.recipes) ~= nil)
        assert(next(self.reagent_id_to_count) ~= nil)
        assert(spell_id_to_craft[self.spell_id] == nil)
    end

    spell_id_to_craft[self.spell_id] = self

    for reagent_id, _ in pairs(self.reagent_id_to_count) do
        local spell_ids = reagent_id_to_spell_ids[reagent_id]
        if spell_ids == nil then
            reagent_id_to_spell_ids[reagent_id] = {}
            spell_ids = reagent_id_to_spell_ids[reagent_id]
        end
        tinsert(spell_ids, self.spell_id)
    end
end

---@return LibCrafts
function LibCraftsGetLibrary()
    return lib
end
