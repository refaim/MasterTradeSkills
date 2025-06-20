setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("esES", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " AddOn cargado"
L.txt_open_options = "Abrir opciones"

L.txt_option_group_enable = "Habilitar"
L.txt_option_enhance_tooltips = "Mejorar descripciones"
L.txt_option_enhance_tooltips_shift = "Mejorar descripciones solo mientras se presiona Shift"

L.txt_option_group_trade_skills = "Habilidades comerciales"

L.txt_option_group_skill_difficulty = "Dificultad de habilidades"
L.txt_option_show_trivial = "Mostrar |cFFA0A0A0Trivial"
L.txt_option_show_easy = "Mostrar |cFF40C040Fбcil"
L.txt_option_show_medium = "Mostrar |cFFFFEE00Medio"
L.txt_option_show_optimal = "Mostrar |cFFFF9900Уptimo"
L.txt_option_show_difficult = "Mostrar |cFFFF0000Difнcil"

L.txt_option_group_details = "Detalles"
L.txt_option_show_learned = "Mostrar habilidades aprendidas"
L.txt_option_show_not_learned = "Mostrar habilidades no aprendidas"
L.txt_option_show_alt_name = "Mostrar nombre del personaje"
L.txt_option_show_cross_faction_alts = "Mostrar personajes de facciones cruzadas"
L.txt_option_how_many_skills_to_show = "Cuбntas habilidades mostrar en la descripciуn"

L.txt_option_group_sorting = "Ordenamiento"
L.txt_option_not_learned_skills_last = "Habilidades no aprendidas al final"
L.txt_option_higher_level_skills_first = "Habilidades de mayor nivel primero"

L.txt_recipes = "Recetas"

L.txt_source_chest = "Cofre"
L.txt_source_craft = "Artesanнa"
L.txt_source_drop = "Botнn"
L.txt_source_fishing = "Pesca"
L.txt_source_gift = "Regalo"
L.txt_source_pickpocketing = "Carterismo"
L.txt_source_quest = "Misiуn"
L.txt_source_trainer = "Entrenador"
L.txt_source_unknown = "Desconocido"
L.txt_source_vendor = "Vendedor"
L.txt_source_world_object = "Objeto"
