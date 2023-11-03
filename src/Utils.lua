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
