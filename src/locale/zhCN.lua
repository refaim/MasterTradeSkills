setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("zhCN", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " 插件已加载"
L.txt_missing_locale = "请告知Refaim缺少\"%s\"的本地化：https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "打开选项"

L.txt_option_group_enable = "启用"
L.txt_option_enhance_tooltips = "增强工具提示"
L.txt_option_enhance_tooltips_shift = "仅在按住Shift键时增强工具提示"

L.txt_option_group_trade_skills = "专业技能"

L.txt_option_group_skill_difficulty = "技能难度"
L.txt_option_show_trivial = "显示|cFFA0A0A0灰色"
L.txt_option_show_easy = "显示|cFF40C040绿色"
L.txt_option_show_medium = "显示|cFFFFEE00黄色"
L.txt_option_show_optimal = "显示|cFFFF9900橙色"
L.txt_option_show_difficult = "显示|cFFFF0000红色"

L.txt_option_group_details = "详细信息"
L.txt_option_show_learned = "显示已学技能"
L.txt_option_show_not_learned = "显示未学技能"
L.txt_option_show_alt_name = "显示角色名称"
L.txt_option_show_cross_faction_alts = "显示跨阵营角色"
L.txt_option_how_many_skills_to_show = "工具提示中显示的技能数量"

L.txt_option_group_sorting = "排序"
L.txt_option_not_learned_skills_last = "未学技能显示在最后"
L.txt_option_higher_level_skills_first = "高等级技能优先显示"

L.txt_recipes = "配方"

L.txt_source_chest = "箱子"
L.txt_source_craft = "制作"
L.txt_source_drop = "掉落"
L.txt_source_fishing = "钓鱼"
L.txt_source_gift = "礼物"
L.txt_source_pickpocketing = "偷窃"
L.txt_source_quest = "任务"
L.txt_source_trainer = "训练师"
L.txt_source_unknown = "未知"
L.txt_source_vendor = "商人"
L.txt_source_world_object = "物体"
