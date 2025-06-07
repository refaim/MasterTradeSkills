# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About MasterTradeSkills

MasterTradeSkills is a World of Warcraft addon for Vanilla WoW and Turtle WoW that enhances item tooltips to show crafting recipe information. It displays which recipes use a particular ingredient, recipe sources, skill requirements, and information about alternate characters who know the recipes.

## Development Environment

This is a WoW addon built with:
- Lua programming language
- Ace3v framework for addon structure
- Type annotations using EmmyLua format
- LibStub for library management

### Key Libraries
- **LibCrafts-1.0**: Recipe database and localization
- **LibCraftingProfessions-1.0**: Profession scanning and skill management  
- **LibItemTooltip-1.0**: Tooltip hooking and enhancement
- **AceAddon-3.0**: Core addon framework
- **AceDB-3.0**: Saved variables and character data management
- **AceConfig-3.0**: Options UI system

## Architecture

### Core Components

**Addon.lua**: Main addon class implementing tooltip enhancement logic
- Hooks into item tooltips via LibItemTooltip
- Creates tooltip data from recipe database queries
- Handles filtering, sorting, and display of recipe information
- Uses setfenv(1, MasterTradeSkills) namespace pattern

**Database/Modern.lua**: Character data persistence and management
- Stores player profession skills and recipe knowledge per character/realm
- Manages cross-character data sharing with faction filtering
- Handles legacy data migration from older addon versions

**Options.lua**: Configuration UI using Ace3 framework
- Dynamic options generation based on supported professions
- Nested option groups for tooltips, difficulty, sorting, etc.
- Integration with Blizzard's interface options panel

### Data Flow

1. LibCraftingProfessions scans player profession windows and fires events
2. Database layer saves skill data per character/realm
3. When hovering over items, LibItemTooltip fires tooltip events
4. Main addon queries LibCrafts for recipes using the item as reagent
5. Recipe data is filtered, sorted and displayed in enhanced tooltips

### File Loading Order (per .toc)

Libraries load first, then core files in dependency order:
Environment.lua → GlobalVariables.lua → Utils.lua → Locales → Database → Options → Addon.lua

## Commands

- `/mts options` - Opens addon configuration window
- No build/test commands - this is a runtime WoW addon

## Key Patterns

- **Namespace isolation**: All files use `setfenv(1, MasterTradeSkills)` 
- **Type annotations**: EmmyLua format for IDE support (`---@type`, `---@param`, etc.)
- **Library access**: Via LibStub pattern for dependency injection
- **Event-driven**: Uses callback registration for profession updates and tooltip events
- **Ace3 patterns**: Standard addon structure with OnInitialize/OnEnable lifecycle

## Localization

Locale files in src/locale/ provide translated strings for supported languages. The addon supports deDE, enUS, esES, frFR, koKR, ptBR, ruRU, zhCN, zhTW locales.

**IMPORTANT**: All locale files must be saved in UTF-8 encoding to properly handle non-ASCII characters in translations.