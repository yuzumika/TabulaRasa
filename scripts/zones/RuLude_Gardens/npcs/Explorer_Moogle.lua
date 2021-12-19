-----------------------------------
-- Area: Ru'Lude Gardens
--  NPC: Explorer Moogle
-- Type: Mog Tablet
-- !pos 1.000 -1 0.000 243 -- TODO: This is wrong
-----------------------------------
require('scripts/globals/mog_tablets')
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    -- blank
end

entity.onTrigger = function(player, npc)
    xi.mogTablet.moogleOnTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option)
    xi.mogTablet.moogleOnEventUpdate(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
    xi.mogTablet.moogleOnEventFinish(player, csid, option)
end

return entity
