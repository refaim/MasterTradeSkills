-- TODO setfenv

-- Database, inspired by BookOfCrafts
--[[
    .Characters                : Indexed table of characters
       [i]                     : Acces to i-th character
          .Name                : Character name
          .Realm               : Character realm
          .Faction             : Character faction
    [tradeskill]               : Contains all known craft objects for "tradeskill" (tailor, alchemy, ...)
       [crafted_object]        : Data for specific "crafted_object"
          .LearntBy[i]         : index in ".Characters" of i-th character who knows this tradeskills
]]--
-- TODO remove this global variables
---@type MasterTradeSkillsLegacyDB
MTS_DATA = {};
MTS_PLAYER_NAME_KNOWN = false;
MTS_DATA_CHECKED = false;

---@type LibStubDef
local LibStub = getglobal("LibStub")
assert(LibStub ~= nil, "Cannot find instance of a LibStub")

---@type LibAceAddonDef
local LibAceAddon = --[[---@type LibAceAddonDef]] LibStub("AceAddon-3.0")

local ADDON_NAME = "MasterTradeSkills"

---@type AceAddonDef
---@field database MasterTradeSkillsDB
---@field options MasterTradeSkillsDBOptions
local MasterTradeSkills = LibAceAddon:NewAddon(ADDON_NAME, "AceConfig-3.0", "AceEvent-3.0", "AceHook-3.0")

---@return LibAceConfigEmbedDef
function MasterTradeSkills:AceConfig()
    return --[[---@type LibAceConfigEmbedDef]] self
end

---@return LibAceEventEmbedDef
function MasterTradeSkills:AceEvent()
    return --[[---@type LibAceEventEmbedDef]] self
end

---@return LibAceHookEmbedDef
function MasterTradeSkills:AceHook()
    return --[[---@type LibAceHookEmbedDef]] self
end

-- TODO keybindings for the options window
function MasterTradeSkills:OnInitialize()
    self.database = MasterTradeSkills_Database:Initialize(LibStub)
    self.options = self.database.char.Options
    MasterTradeSkills_Options:Initialize(ADDON_NAME, self.options, self:AceConfig())
end

function MasterTradeSkills:OnEnable()
    ---@type table<string, function>
    local reagent_data_loaders = {
        alchemy = ReagentData_LoadAlchemy,
        blacksmithing = ReagentData_LoadBlacksmithing,
        cooking = ReagentData_LoadCooking,
        enchanting = ReagentData_LoadEnchanting,
        engineering = ReagentData_LoadEngineering,
        firstaid = ReagentData_LoadFirstAid,
        leatherworking = ReagentData_LoadLeatherworking,
        mining = ReagentData_LoadMining,
        poisons = ReagentData_LoadPoisons,
        tailoring = ReagentData_LoadTailoring,
    }
    ---@type table<string, any>
    local database = ReagentData['crafted']
    for profession, loader in pairs(reagent_data_loaders) do
        if database[profession] == nil then
            loader()
        end
    end

    self:AceEvent():RegisterEvent("TRADE_SKILL_SHOW", function(event) MasterTradeSkills_ReadRecipes() end)
    self:AceEvent():RegisterEvent("TRADE_SKILL_UPDATE", function(event) MasterTradeSkills_ReadRecipes() end)

    self:AceEvent():RegisterEvent("CRAFT_SHOW", function(event) MasterTradeSkills_ReadCrafts() end)
    self:AceEvent():RegisterEvent("CRAFT_UPDATE", function(event) MasterTradeSkills_ReadCrafts() end)

    ---@return boolean
    local function is_player_name_known()
        local name, _ = UnitName("player")
        return name ~= nil and name ~= "" and name ~= UNKNOWNOBJECT
    end

    self:AceEvent():RegisterEvent("PLAYER_ENTERING_WORLD", function(event)
        if is_player_name_known() then
            MTS_PLAYER_NAME_KNOWN = true
            MasterTradeSkills_InitData()
        end
    end)

    self:AceEvent():RegisterEvent("UNIT_NAME_UPDATE", function(event, unit)
        if unit == "player" and is_player_name_known() then
            MTS_PLAYER_NAME_KNOWN = true
            MasterTradeSkills_InitData()
        end
    end)

    self:AceHook():SecureHook("SetItemRef", "PostHookSetItemRef")
    self:AceHook():HookScript(GameTooltip, "OnShow", "PreHookGameTooltipShow")

    -- TODO use AceLocale
    if (GetLocale() == "deDE") then
        MasterTradeSkills_LoadGerman();
    elseif (GetLocale() == "frFR") then
        MasterTradeSkills_LoadFrench();
    elseif (GetLocale() == "ruRU") then
        MasterTradeSkills_LoadRussian()
    end

    MasterTradeSkills_Write(MTS_LOADED);
end

function MasterTradeSkills:PostHookSetItemRef(link, text, button)
    local prefix_supported = strsub(link, 1, strlen("item")) == "item"
    if prefix_supported and not IsControlKeyDown() and not IsShiftKeyDown() then
        local name, _, _, _, _, _, _, _, _ = GetItemInfo(link);
        self:EnhanceTooltip(ItemRefTooltip, name)
        ItemRefTooltip:Show()
    end
end

function MasterTradeSkills:PreHookGameTooltipShow()
    if not MTS_PLAYER_NAME_KNOWN or not MTS_DATA_CHECKED then
        return
    end

    local enabled = self.options.EnhanceTooltips
        and (IsShiftKeyDown() or not self.options.EnhanceTooltipsOnlyWhileShiftIsPressed)
        and (self.options.EnhanceMinimapNodesTooltips or not MouseIsOver(MinimapCluster))
    if not enabled then
        return
    end

    -- TODO refactor
    local lbl = getglobal("GameTooltipTextLeft1");
    if lbl then
        local name = lbl:GetText();
        name = string.gsub(name, "Vein","Ore");
        name = string.gsub(name, "Deposit","Ore");
        if ( strfind(name,"Ore") ~= nil ) then
            name = string.gsub(name, "Rich ","");
            name = string.gsub(name, "Small ","");
            name = string.gsub(name, "Ooze Covered ","");
        end
        self:EnhanceTooltip(GameTooltip, name);
    end
end

function MasterTradeSkills_InitData()
    if((MTS_PLAYER_NAME_KNOWN) and (not MTS_DATA_CHECKED) ) then
        MTS_CHAR_NAME    = UnitName( "player" )
        MTS_CHAR_REALM   = GetCVar( "realmName" )
        MTS_CHAR_FACTION = UnitFactionGroup( "player" )

        if( not MTS_DATA.Characters ) then
            MTS_DATA.Characters = {};
        end

        -- Find character name
        local nb_chars = table.getn( MTS_DATA.Characters );
        MTS_CHAR_INDEX = nil;

        for i = 1, nb_chars do
            if((MTS_DATA.Characters[i].Name==MTS_CHAR_NAME) and
                (MTS_DATA.Characters[i].Realm==MTS_CHAR_REALM) and
                (MTS_DATA.Characters[i].Faction==MTS_CHAR_FACTION)) then
                MTS_CHAR_INDEX = i;
                break
            end
        end

        -- if not found, register new character
        if( MTS_CHAR_INDEX==nil ) then
            MTS_CHAR_INDEX = nb_chars+1;
            MTS_DATA.Characters[MTS_CHAR_INDEX] = {};
            MTS_DATA.Characters[MTS_CHAR_INDEX].Name    = MTS_CHAR_NAME;
            MTS_DATA.Characters[MTS_CHAR_INDEX].Realm   = MTS_CHAR_REALM;
            MTS_DATA.Characters[MTS_CHAR_INDEX].Faction = MTS_CHAR_FACTION;
        end

        MTS_DATA_CHECKED = true;
    end
end

function MasterTradeSkills:EnhanceTooltip(frame, name) -- TODO change signature
    local professions = ReagentData_GetProfessions(name);
    local totalcount = 0;
    -- text will hold the recipes to be written to the frame.
    local textleft = "";
    local prechar = "";
    local textright = "";
    local textline = 1;
    local skill = nil;
    local source = "";
    local MTS_Max = table.getn(MTS_TRADESKILLS);
    local count = {};
    for i=1, MTS_Max do
        count[MTS_TRADESKILLS[i]] = 0;
    end

    local endsource = 0;
    local skilllevel_color = "";
    -- Make a new database for the tooltip
    local MTS_TOOLTIP_DB = {};
    local MTS_TOOLTIP_SKILLEVEL = 0;

    local recipe_source_color = "|cFF56B59D"
    local learnable_color = "|cFF00FF00"
    local unlearnable_color = "|cFFFF0000"
    ---@type table<number, string>
    local skill_level_to_color = {
        [1] = "|cFFA0A0A0";
        [2] = "|cFF40C040";
        [3] = "|cFFFFEE00";
        [4] = "|cFFFF9900";
        [5] = "|cFFFF0000";
    };

    if ( professions == nil ) then return end

    -- Loop through the professions and recipes
    for key, value in professions do
        local trade_skill_index = MasterTradeSkill_IsTradeSkill(value)
        local rd_trade_skill_id = MTS_TRADESKILLS_NAME[trade_skill_index]
        local tsd_profession_id = MTS_TSD_PROFESSION_ID[trade_skill_index]
        if (rd_trade_skill_id ~= nil and tsd_profession_id ~= nil and self.options.ShowSkillsByTradeSkill[tsd_profession_id]) then
            -- Clear Tooltip Database
            MTS_TOOLTIP_DB = {};
            for Recipes in ReagentData['crafted'][rd_trade_skill_id] do
                for Reagents in ReagentData['crafted'][rd_trade_skill_id][Recipes]['reagents'] do
                    if (name == Reagents) then
                        local MTS_SkillLevel = MasterTradeSkills_GetSkillLevel(value);
                        textleft = "";
                        textright = "";
                        -- Get the skill level and source of the recipe
                        skill = ReagentData['crafted'][rd_trade_skill_id][Recipes]['skill'];
                        source = ReagentData['crafted'][rd_trade_skill_id][Recipes]['source'];
                        -- Filter out the source
                        endsource = string.find(source, ":");
                        if (endsource ~= nil) then
                            source = string.sub(source, 1 , endsource -1);
                        elseif (source == "") then
                            source = "?";
                        end
                        -- Look if the skill is know, and what color it is
                        skilllevel_color = "";
                        local AltKnown = 0;
                        local AltKnownBy = "";
                        local localeRecipes = MTS_RECIPENAME[Recipes];
                        -- First check if the data is read
                        if (MTS_DATA[value] ~= nil) then
                            -- Second check if the recipe is in the MTS database
                            if (MTS_DATA[value][localeRecipes] ~= nil) then
                                -- Third look if it has been learnt by someone
                                if (MTS_DATA[value][localeRecipes].LearntBy ~= nil) then
                                    -- Fourth check if the current user has learnt it
                                    AltKnown = 1;
                                    if (MTS_DATA[value][localeRecipes].LearntBy[MTS_CHAR_INDEX] ~= nil) then
                                        for i=1,4 do
                                            if (MTS_DATA[value][localeRecipes].LearntBy[MTS_CHAR_INDEX] == MTS_TRADESKILL_SKILLLEVEL[i]) then
                                                skilllevel_color = skill_level_to_color[i];
                                                AltKnown = 0
                                            end
                                        end
                                    else
                                    local nb_chars = table.getn( MTS_DATA.Characters );
                                        for i=1, nb_chars do
                                            if (MTS_DATA[value][localeRecipes].LearntBy[i] ~= nil ) then
                                                    for q=1,4 do
                                                        if (MTS_DATA[value][localeRecipes].LearntBy[i] == MTS_TRADESKILL_SKILLLEVEL[q]) then
                                                            Altskilllevel_color = skill_level_to_color[q];
                                                        end
                                                    end
                                                if ( MTS_DATA.Characters[i].Realm == MTS_DATA.Characters[MTS_CHAR_INDEX].Realm and MTS_DATA.Characters[i].Faction == MTS_DATA.Characters[MTS_CHAR_INDEX].Faction) then
                                                AltKnownBy = AltKnownBy .."  |r" .. Altskilllevel_color .. "[".. MTS_DATA.Characters[i].Name .."]|r";
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if (skilllevel_color == ""  ) then
                            if ( AltKnownBy ~= "") then
                                skilllevel_color = recipe_source_color;
                            else
                                skilllevel_color = skill_level_to_color[5];
                            end
                        end
                        -- Make the texts for in the tooltip
                        local MTS_ShowTooltip = true;
                        -- Options: Show Learned
                        if (skilllevel_color ~= skill_level_to_color[5] and not self.options.ShowSkillsByStatus.Learned) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Not Learned
                        if (skilllevel_color == skill_level_to_color[5] and not self.options.ShowSkillsByStatus.NotLearned) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Trivial
                        if (skilllevel_color == skill_level_to_color[1] and not self.options.ShowSkillsByDifficulty.Trivial ) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Easy
                        if (skilllevel_color == skill_level_to_color[2] and not self.options.ShowSkillsByDifficulty.Easy ) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Medium
                        if (skilllevel_color == skill_level_to_color[3] and not self.options.ShowSkillsByDifficulty.Medium ) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Optimal
                        if (skilllevel_color == skill_level_to_color[4] and not self.options.ShowSkillsByDifficulty.Optimal ) then
                            MTS_ShowTooltip = false;
                        end
                        -- Options: Show Too High
                        if (skilllevel_color == skill_level_to_color[5] and not self.options.ShowSkillsByDifficulty.Difficult ) then
                            MTS_ShowTooltip = false;
                        end

                        -- Options: How Many so far Vs Number to show
                        if ( totalcount + 1 > self.options.HowManySkillsToShow ) then
                            MTS_ShowTooltip = false;
                        end

                            local localeRecipes = MTS_RECIPENAME[Recipes];
                            if (localeRecipes == nil) then
                                localeRecipes = Recipes
                                MasterTradeSkills_Write(MTS_UNKNOWN..Recipes);
                            end

                            -- Source Locales
                                if ( source == "Vendor") then source = MTS_RVENDOR;
                                elseif ( source == "Trainer") then source = MTS_RTRAINER;
                                elseif ( source == "Drop") then source = MTS_RDROP;
                                elseif ( source == "Unknown") then source = MTS_RUNKNOWN;
                                elseif ( source == "Quest") then source = MTS_RQUEST;
                                end

                            isreagent = {};
                            isreagent = ReagentData_GetProfessions(localeRecipes);
                                prechar = " -";
                            if ( isreagent == nil ) then

                            else
                                for key, value in isreagent do
                                prechar = "+";
                                end
                            end
                            textleft = "|cFFFFB444" .. " ".. prechar .."|r" .. skilllevel_color .. localeRecipes .. "|r";
                            textright = recipe_source_color .. source .. "|r ";
                            if (skill ~= nil and skill ~= "") then
                                if (skill > MTS_SkillLevel) then
                                    textright = textright .. unlearnable_color .. "(" ..  skill .. ")|r";
                                else
                                    textright = textright .. learnable_color .. "(" ..  skill .. ")|r";
                                end
                            else
                                if (skill == nil or skill == "") then
                                    skill = "?";
                                end
                                textright = textright .. learnable_color .. "(" ..  skill .. ")|r";
                            end
                            count[value] = count[value] + 1;
                            -- If this is the first time a recipe is being added, add a explanation line
                            if (count[value] == 1) then
                                if ( MTS_ShowTooltip == true ) then
                                    local color = "|cFF00FF11"
                                    frame:AddDoubleLine(color .. MTS_RECIPES .. "|r", color .. value .. " (" .. MTS_SkillLevel .. ")|r");
                                end
                            end

                            if AltKnownBy ~= "" and self.options.ShowAltName then
                               textright = AltKnownBy;
                            end

                            -- Add the tooltip
                            MTS_TOOLTIP_SKILLEVEL = 0;
                            for i=1,5 do
                                if(skilllevel_color== skill_level_to_color[i]) then
                                    MTS_TOOLTIP_SKILLEVEL = i;
                                    if self.options.SortingOptions.NotLearnedSkillsLast then
                                        if (MTS_TOOLTIP_SKILLEVEL == 5) then MTS_TOOLTIP_SKILLEVEL = 0; end
                                    end
                                end
                            end
                        if (MTS_ShowTooltip == true) then
                            totalcount = totalcount+1
                            table.insert(MTS_TOOLTIP_DB, {skilllvl=MTS_TOOLTIP_SKILLEVEL,{name=Recipes, textl=textleft, textr=textright}});
                        end
                    end
                end
            end

            -- TODO sort not only by COLOR but by real skill level
            -- TODO sort and THEN limit count
            -- TODO sort by lvl then by some other criteria
            local compare
            if self.options.SortingOptions.HigherLevelSkillsFirst then
                compare = function (a, b) return a.skilllvl > b.skilllvl end
            else
                compare = function (a, b) return a.skilllvl < b.skilllvl end
            end
            table.sort(MTS_TOOLTIP_DB, compare);

            for i=1, table.getn(MTS_TOOLTIP_DB) do
                for j=1, table.getn(MTS_TOOLTIP_DB[i]) do
                    frame:AddDoubleLine(MTS_TOOLTIP_DB[i][j].textl, MTS_TOOLTIP_DB[i][j].textr);
                end
            end
            MTS_TOOLTIP_DB = {};
        end
    end
end

function MasterTradeSkills_Write(chat_text)
    DEFAULT_CHAT_FRAME:AddMessage(chat_text, 0.0, 1.0, 0.0);
end

function MasterTradeSkills_ReadRecipes()
    local tradeskill, trade_rank = GetTradeSkillLine();
    if (MasterTradeSkill_IsTradeSkill(tradeskill)) then
        for i=1, GetNumTradeSkills() do
            local crafted_object, skill_type = GetTradeSkillInfo(i);
            if (MTS_DATA[tradeskill] == nil) then
                MTS_DATA[tradeskill] = {};
            end
            if (MTS_DATA[tradeskill][crafted_object] == nil) then
                MTS_DATA[tradeskill][crafted_object] = {};
                MTS_DATA[tradeskill][crafted_object].LearntBy = {};
                MTS_DATA[tradeskill][crafted_object].LearntBy[MTS_CHAR_INDEX] = skill_type;
            else
                MTS_DATA[tradeskill][crafted_object].LearntBy[MTS_CHAR_INDEX] = skill_type;
            end
        end
    end
end

function MasterTradeSkills_ReadCrafts()
    local tradeskill, trade_rank = GetCraftDisplaySkillLine();
    if (tradeskill and MasterTradeSkill_IsTradeSkill(tradeskill)) then
        for i=1, GetNumCrafts() do
            local crafted_object, craftSubSpellName, skill_type = GetCraftInfo(i);

            if (MTS_DATA[tradeskill] == nil) then
                MTS_DATA[tradeskill] = {};
            end
            if (MTS_DATA[tradeskill][crafted_object] == nil) then
                MTS_DATA[tradeskill][crafted_object] = {};
                MTS_DATA[tradeskill][crafted_object].LearntBy = {};
                MTS_DATA[tradeskill][crafted_object].LearntBy[MTS_CHAR_INDEX] = skill_type;
            else
                MTS_DATA[tradeskill][crafted_object].LearntBy[MTS_CHAR_INDEX] = skill_type;
            end
        end
    end
end

function MasterTradeSkills_GetSkillLevel(skill)
    local tradeSkillsNum = GetNumSkillLines();
    local MTS_GetSkillLevel = 0;

    for i=1,tradeSkillsNum do
        local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(i);
        if (skillName == skill) then
            MTS_GetSkillLevel = skillRank;
        end
    end

    return MTS_GetSkillLevel;
end

function MasterTradeSkill_IsTradeSkill(skill)
    local MTS_IsTradeSkill = 0;
    local MTS_Max = table.getn(MTS_TRADESKILLS);
    for i=1, MTS_Max do
        if (skill == MTS_TRADESKILLS[i]) then
            MTS_IsTradeSkill = i;
        end
    end
    return MTS_IsTradeSkill
end
