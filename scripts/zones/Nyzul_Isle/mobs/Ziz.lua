-----------------------------------
--  MOB: Ziz
-- Area: Nyzul Isle
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    xi.nyzul.specifiedEnemySet(mob)
    mob:setAnimationSub(13)
end

entity.onMobDeath = function(mob, player, isKiller, noKiller)
    if isKiller or noKiller then
        xi.nyzul.spawnChest(mob, player)
        xi.nyzul.specifiedEnemyKill(mob)
    end
end

return entity