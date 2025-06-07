setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("ptBR", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " AddOn carregado"
L.txt_missing_locale = "Por favor, informe ao Refaim que a localização para \"%s\" está faltando: https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "Abrir opções"

L.txt_option_group_enable = "Ativar"
L.txt_option_enhance_tooltips = "Melhorar tooltips"
L.txt_option_enhance_tooltips_shift = "Melhorar tooltips apenas enquanto Shift estiver pressionado"

L.txt_option_group_trade_skills = "Profissões"

L.txt_option_group_skill_difficulty = "Dificuldade da habilidade"
L.txt_option_show_trivial = "Mostrar |cFFA0A0A0Trivial"
L.txt_option_show_easy = "Mostrar |cFF40C040Fácil"
L.txt_option_show_medium = "Mostrar |cFFFFEE00Médio"
L.txt_option_show_optimal = "Mostrar |cFFFF9900Ótimo"
L.txt_option_show_difficult = "Mostrar |cFFFF0000Difícil"

L.txt_option_group_details = "Detalhes"
L.txt_option_show_learned = "Mostrar habilidades aprendidas"
L.txt_option_show_not_learned = "Mostrar habilidades não aprendidas"
L.txt_option_show_alt_name = "Mostrar nome do personagem"
L.txt_option_show_cross_faction_alts = "Mostrar personagens de facções cruzadas"
L.txt_option_how_many_skills_to_show = "Quantas habilidades mostrar no tooltip"

L.txt_option_group_sorting = "Ordenação"
L.txt_option_not_learned_skills_last = "Habilidades não aprendidas por último"
L.txt_option_higher_level_skills_first = "Habilidades de nível mais alto primeiro"

L.txt_recipes = "Receitas"

L.txt_source_chest = "Baú"
L.txt_source_craft = "Artesanato"
L.txt_source_drop = "Drop"
L.txt_source_fishing = "Pesca"
L.txt_source_gift = "Presente"
L.txt_source_pickpocketing = "Batedor de carteira"
L.txt_source_quest = "Missão"
L.txt_source_trainer = "Treinador"
L.txt_source_unknown = "Desconhecido"
L.txt_source_vendor = "Vendedor"
L.txt_source_world_object = "Objeto"
