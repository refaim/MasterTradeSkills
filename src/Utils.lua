---@class MasterTradeSkills_Utils
MasterTradeSkills_Utils = {}

---@param tbl table|any[]
---@return boolean
function MasterTradeSkills_Utils:IsTableEmpty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

---@param code LocaleCode
---@param is_default boolean
---@return MasterTradeSkillsLocale|nil
function MasterTradeSkills_Utils:NewLocale(code, is_default)
    ---@type LibStubDef
    local LibStub = getglobal("LibStub")
    assert(LibStub ~= nil, "Cannot find instance of a LibStub")

    local AceLocale = --[[---@type LibAceLocaleDef]] LibStub("AceLocale-3.0")
    local L = --[[---@type MasterTradeSkillsLocale]] AceLocale:NewLocale(MTS_NAME, code, is_default)
    if is_default then
        assert(L ~= nil)
    end

    return L
end
