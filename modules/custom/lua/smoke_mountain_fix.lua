-----------------------------------
-- Area: South Gustaberg
--  NPC: ???
-- Involved in Quest: Smoke on the Mountain
-- Change to 1 hour timer
-----------------------------------
local ID = require("scripts/zones/South_Gustaberg/IDs")
require("scripts/globals/npc_util")
require("scripts/globals/quests")
-----------------------------------
local entity = {}
local m = Module:new("smoke_mountain_fix")

m:addOverride("xi.zones.South_Gustaberg.npcs.qm2.onTrade", function(player, npc, trade)
    if not player:needToZone() then
        player:setCharVar("SGusta_Sausage_Timer", 0)
    end
    if npcUtil.tradeHas(trade, 4372) then
        if player:getCharVar("SGusta_Sausage_Timer") == 0 then
            -- player puts sheep meat on the fire
            player:messageSpecial(ID.text.FIRE_PUT, 4372)
            player:confirmTrade()
            player:setCharVar("SGusta_Sausage_Timer", os.time() + 3600) -- 1 hour earth time
            player:needToZone(true)
        else
            -- message given if sheep meat is already on the fire
            player:messageSpecial(ID.text.MEAT_ALREADY_PUT, 4372)
        end
    end
end)

return m

