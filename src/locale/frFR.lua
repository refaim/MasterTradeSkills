setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("frFR", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " AddOn charg\195\169"
L.txt_open_options = "Options ouvertes"

L.txt_option_group_enable = "Activer"
L.txt_option_enhance_tooltips = "Améliorer les info-bulles"
L.txt_option_enhance_tooltips_shift = "Améliorer les info-bulles uniquement lorsque la touche Maj est enfoncée"

L.txt_option_group_trade_skills = "Compétences commerciales"

L.txt_option_group_skill_difficulty = "Difficulté de compétence"
L.txt_option_show_trivial = "Afficher |cFFA0A0A0Insignifiant"
L.txt_option_show_easy = "Afficher |cFF40C040Facile"
L.txt_option_show_medium = "Afficher |cFFFFEE00Normal"
L.txt_option_show_optimal = "Afficher |cFFFF9900Optimal"
L.txt_option_show_difficult = "Afficher |cFFFF0000Difficile"

L.txt_option_group_details = "Détails"
L.txt_option_show_learned = "Afficher les recettes connues"
L.txt_option_show_not_learned = "Afficher les recettes iconnues"
L.txt_option_show_alt_name = "Montrer nom du perso"
L.txt_option_show_cross_faction_alts = "Show cross-faction alts"
L.txt_option_how_many_skills_to_show = "Lignes Max. \195\160 afficher dans le tooltip"

L.txt_option_group_sorting = "Tri"
L.txt_option_not_learned_skills_last = "Recettes inconnues en dernier"
L.txt_option_higher_level_skills_first = "Afficher recette de haut niveau d'abord"

L.txt_recipes = "Recettes"

L.txt_source_chest = "Boîte"
L.txt_source_craft = "Artisanat"
L.txt_source_drop = "Ramass\195\169"
L.txt_source_fishing = "Pêche"
L.txt_source_gift = "Cadeau"
L.txt_source_pickpocketing = "Vol à la tire"
L.txt_source_quest = "Qu\195\170te"
L.txt_source_trainer = "Instructeur"
L.txt_source_unknown = "Inconnu"
L.txt_source_vendor = "Marchand"
L.txt_source_world_object = "Objet"
