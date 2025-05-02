local lib = LibCraftsGetLibrary()
local name, locale, version = "Locales-Professions", "deDE", 1
local module = --[[---@type LcLocaleModule]] lib:RegisterLocaleModule(name, locale, version)
if not module then return end

local L = module:GetStrings()
L["Alchemy"] = "Alchimie"
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
