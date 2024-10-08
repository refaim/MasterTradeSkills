setfenv(1, MasterTradeSkills)

---@class MasterTradeSkills_Utils
MasterTradeSkills_Utils = {}

---@param code LocaleCode
---@param is_default boolean
---@return MasterTradeSkillsLocale|nil
function MasterTradeSkills_Utils:NewLocale(code, is_default)
    ---@type LibStubDef
    local LibStub = getglobal("LibStub")
    assert(LibStub ~= nil, "Cannot find instance of a LibStub")

    local AceLocale, _ = LibStub("AceLocale-3.0")
    local L = --[[---@type MasterTradeSkillsLocale]] AceLocale:NewLocale(MtsAddonName, code, is_default)
    if is_default then
        assert(L ~= nil)
    end

    return L
end
