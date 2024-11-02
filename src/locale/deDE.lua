setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("deDE", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " AddOn geladen"
L.txt_missing_locale = "Bitte informieren Sie Refaim, dass das Gebietsschema für \"%s\" fehlt: https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "Offene Optionen"

L.txt_option_group_enable = "Aktivieren"
L.txt_option_enhance_tooltips = "Tooltips verbessern"
L.txt_option_enhance_tooltips_shift = "Verbessern Sie Tooltips nur, während die Umschalttaste gedrückt wird"

L.txt_option_group_trade_skills = "Handelskompetenzen"

L.txt_option_group_skill_difficulty = "Fähigkeitsschwierigkeit"
L.txt_option_show_trivial = "Zeige |cFFA0A0A0Trivial"
L.txt_option_show_easy = "Zeige |cFF40C040Leicht"
L.txt_option_show_medium = "Zeige |cFFFFEE00Mittel"
L.txt_option_show_optimal = "Zeige |cFFFF9900Optimal"
L.txt_option_show_difficult = "Zeige |cFFFF0000Schwierig"

L.txt_option_group_details = "Einzelheiten"
L.txt_option_show_learned = "Bereits bekannte Rezepte anzeigen"
L.txt_option_show_not_learned = "Nicht bekannte Rezepte anzeigen"
L.txt_option_show_alt_name = "Charnamen zeigen"
L.txt_option_show_cross_faction_alts = "Show cross-faction alts"
L.txt_option_how_many_skills_to_show = "Max. Zeilenanzahl die im Tooltip angezeigt wird"

L.txt_option_group_sorting = "Sortierung"
L.txt_option_not_learned_skills_last = "Unbekannte Rezepte zuletzt"
L.txt_option_higher_level_skills_first = "Schwere Rezepte zuerst"

L.txt_recipes = "Rezepte"

L.txt_source_chest = "Truhe"
L.txt_source_craft = "Handwerk"
L.txt_source_drop = "Drop"
L.txt_source_fishing = "Angeln"
L.txt_source_gift = "Geschenk"
L.txt_source_pickpocketing = "Taschendiebstahl"
L.txt_source_quest = "Quest"
L.txt_source_trainer = "Lehrer"
L.txt_source_unknown = "Unbekannt"
L.txt_source_vendor = "H\195\164ndler"
L.txt_source_world_object = "Objekt"
