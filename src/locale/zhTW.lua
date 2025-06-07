setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("zhTW", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " 插件已載入"
L.txt_missing_locale = "請告知Refaim缺少\"%s\"的本地化：https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "開啟選項"

L.txt_option_group_enable = "啟用"
L.txt_option_enhance_tooltips = "增強工具提示"
L.txt_option_enhance_tooltips_shift = "僅在按住Shift鍵時增強工具提示"

L.txt_option_group_trade_skills = "專業技能"

L.txt_option_group_skill_difficulty = "技能難度"
L.txt_option_show_trivial = "顯示|cFFA0A0A0灰色"
L.txt_option_show_easy = "顯示|cFF40C040綠色"
L.txt_option_show_medium = "顯示|cFFFFEE00黃色"
L.txt_option_show_optimal = "顯示|cFFFF9900橙色"
L.txt_option_show_difficult = "顯示|cFFFF0000紅色"

L.txt_option_group_details = "詳細資訊"
L.txt_option_show_learned = "顯示已學技能"
L.txt_option_show_not_learned = "顯示未學技能"
L.txt_option_show_alt_name = "顯示角色名稱"
L.txt_option_show_cross_faction_alts = "顯示跨陣營角色"
L.txt_option_how_many_skills_to_show = "工具提示中顯示的技能數量"

L.txt_option_group_sorting = "排序"
L.txt_option_not_learned_skills_last = "未學技能顯示在最後"
L.txt_option_higher_level_skills_first = "高等級技能優先顯示"

L.txt_recipes = "配方"

L.txt_source_chest = "箱子"
L.txt_source_craft = "製作"
L.txt_source_drop = "掉落"
L.txt_source_fishing = "釣魚"
L.txt_source_gift = "禮物"
L.txt_source_pickpocketing = "偷竊"
L.txt_source_quest = "任務"
L.txt_source_trainer = "訓練師"
L.txt_source_unknown = "未知"
L.txt_source_vendor = "商人"
L.txt_source_world_object = "物體"
