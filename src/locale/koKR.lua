setfenv(1, MasterTradeSkills)

local L = --[[---@type MasterTradeSkillsLocale]] MasterTradeSkills_Utils:NewLocale("koKR", false)
if L == nil then return end

L.txt_addon_loaded = "Master Trade Skills v".. MtsAddonVersion .. " 애드온 로드됨"
L.txt_missing_locale = "Refaim에게 \"%s\"에 대한 로케일이 누락되었음을 알려주세요: https://github.com/refaim/MasterTradeSkills/issues/new"
L.txt_open_options = "옵션 열기"

L.txt_option_group_enable = "활성화"
L.txt_option_enhance_tooltips = "툴팁 향상"
L.txt_option_enhance_tooltips_shift = "Shift를 누르고 있을 때만 툴팁 향상"

L.txt_option_group_trade_skills = "전문 기술"

L.txt_option_group_skill_difficulty = "기술 난이도"
L.txt_option_show_trivial = "|cFFA0A0A0하급|r 표시"
L.txt_option_show_easy = "|cFF40C040쉬움|r 표시"
L.txt_option_show_medium = "|cFFFFEE00보통|r 표시"
L.txt_option_show_optimal = "|cFFFF9900최적|r 표시"
L.txt_option_show_difficult = "|cFFFF0000어려움|r 표시"

L.txt_option_group_details = "세부사항"
L.txt_option_show_learned = "학습한 기술 표시"
L.txt_option_show_not_learned = "학습하지 않은 기술 표시"
L.txt_option_show_alt_name = "부캐릭터 이름 표시"
L.txt_option_show_cross_faction_alts = "다른 진영 부캐릭터 표시"
L.txt_option_how_many_skills_to_show = "툴팁에 표시할 기술 수"

L.txt_option_group_sorting = "정렬"
L.txt_option_not_learned_skills_last = "학습하지 않은 기술을 마지막에"
L.txt_option_higher_level_skills_first = "높은 레벨 기술을 먼저"

L.txt_recipes = "조리법"

L.txt_source_chest = "상자"
L.txt_source_craft = "제작"
L.txt_source_drop = "드롭"
L.txt_source_fishing = "낚시"
L.txt_source_gift = "선물"
L.txt_source_pickpocketing = "소매치기"
L.txt_source_quest = "퀘스트"
L.txt_source_trainer = "훈련사"
L.txt_source_unknown = "알 수 없음"
L.txt_source_vendor = "상인"
L.txt_source_world_object = "오브젝트"
