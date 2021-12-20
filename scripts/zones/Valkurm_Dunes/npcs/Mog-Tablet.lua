-----------------------------------
-- Area: Valkurm Dunes
--  NPC: Mog-Tablet
-----------------------------------
require("scripts/globals/mog_tablets")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    xi.mogTablet.tabletOnTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
end

return entity
