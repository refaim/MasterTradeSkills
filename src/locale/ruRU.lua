setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("ruRU", false)
if L == nil then return end

L.txt_addon_loaded = format("Аддон Master Trade Skills v%s успешно загружен", MtsAddonVersion)
L.txt_missing_locale = "Пожалуйста, сообщите Refaim, что локаль для \"%s\" отсутствует: https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "Открыть настройки"

L.txt_option_group_enable = "Состояние"
L.txt_option_enhance_tooltips = "Показывать навыки в тултипе"
L.txt_option_enhance_tooltips_shift = "Показывать навыки в тултипе, если нажата клавиша Shift"

L.txt_option_group_trade_skills = "Профессии"

L.txt_option_group_skill_difficulty = "Настройки сложности навыков"
L.txt_option_show_trivial = "Показывать |cFFA0A0A0простейшие"
L.txt_option_show_easy = "Показывать |cFF40C040легкие"
L.txt_option_show_medium = "Показывать |cFFFFEE00средние"
L.txt_option_show_optimal = "Показывать |cFFFF9900оптимальные"
L.txt_option_show_difficult = "Показывать |cFFFF0000сложные"

L.txt_option_group_details = "Детали"
L.txt_option_show_learned = "Показывать изученные навыки"
L.txt_option_show_not_learned = "Показывать неизученные навыки"
L.txt_option_show_alt_name = "Показывать имена альтов"
L.txt_option_show_cross_faction_alts = "Показывать альтов из другой фракции"
L.txt_option_how_many_skills_to_show = "Сколько навыков показывать в тултипе"

L.txt_option_group_sorting = "Сортировка"
L.txt_option_not_learned_skills_last = "Показывать неизученные навыки внизу списка"
L.txt_option_higher_level_skills_first = "Показывать более сложные навыки наверху списка"

L.txt_recipes = "Рецепты"

L.txt_source_chest = "Сундуки"
L.txt_source_craft = "Крафт"
L.txt_source_drop = "Дроп"
L.txt_source_fishing = "Рыбалка"
L.txt_source_gift = "Подарок"
L.txt_source_pickpocketing = "Воровство"
L.txt_source_quest = "Задание"
L.txt_source_trainer = "Тренер"
L.txt_source_unknown = "Неизвестно"
L.txt_source_vendor = "Продавец"
L.txt_source_world_object = "Объект"
