-----------------------------------
-- Area: The Eldieme Necropolis
--   NM: Skull of Wrath
-----------------------------------
require("scripts/globals/hunts")
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, isKiller)
    xi.hunts.checkHunt(mob, player, 190)
end

return entity