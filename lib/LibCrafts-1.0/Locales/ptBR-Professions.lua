local lib = LibCraftsGetLibrary()
local name, locale, version = "Locales-Professions", "ptBR", 4
local module = --[[---@type LcLocaleModule]] lib:RegisterLocaleModule(name, locale, version)
if not module then return end

local L = module:GetStrings()
L["Alchemy"] = "Alquimia"
L["Blacksmithing"] = "Ferraria"
L["Cooking"] = "Culinária"
L["Enchanting"] = "Encantamento"
L["Engineering"] = "Engenharia"
L["First Aid"] = "Primeiros Socorros"
L["Leatherworking"] = "Couraria"
L["Mining"] = "Mineração"
L["Poisons"] = "Venenos"
L["Tailoring"] = "Alfaiataria"

if lib.env.is_turtle_wow then
    L["Enchanting"] = "Encantador"
    L["First Aid"] = "Primeiro socorro"
    L["Jewelcrafting"] = "Joalheria"
    L["Leatherworking"] = "Couro"
end
