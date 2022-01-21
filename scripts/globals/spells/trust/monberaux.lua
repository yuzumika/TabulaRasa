-----------------------------------
-- Trust: Monberaux
-----------------------------------
require("scripts/globals/trust")
-----------------------------------
local spell_object = {}

local statusRemovalCooldown = 10
local healingMoveCooldown = 10

spell_object.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spell_object.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spell_object.onMobSpawn = function(mob)
    -- TODO: Summon: I am Doctor Monberaux. My services are available for any affliction.
    -- TODO: Summon (1 dose of Final Elixir ready): I received a vial of a most valuable medicine. It should prove useful in times of emergency.
    -- TODO: Summon (2 doses of Final Elixir ready): I received two vials of a most valuable medicine. They should prove useful in times of emergency.
    xi.trust.message(mob, xi.trust.message_offset.SPAWN)

    -- Tends to be particular about which potions to use. Seems to favor healing for just the
    -- right amount of HP instead of defaulting to the highest-rank potion.
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 700, ai.r.MS, ai.s.SPECIFIC, 4237, healingMoveCooldown) -- Mix: Max Potion
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 500, ai.r.MS, ai.s.SPECIFIC, 4236, healingMoveCooldown) -- Max Potion
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 250, ai.r.MS, ai.s.SPECIFIC, 4235, healingMoveCooldown) -- Hyper Potion

    -- Seems to only use Elemental Power with an offensive caster in the group.

    -- Uses Ethers when party members are ~50% MP.
    mob:addSimpleGambit(ai.t.PARTY, ai.c.MPP_LT, 50, ai.r.MS, ai.s.SPECIFIC, 4254, statusRemovalCooldown) -- Mix: Dry Ether Concoction

    -- Uses Life Water when multiple party members hit yellow HP.

    -- Except for the occasional application of Dark Potion, does not attack or cast spells.
    mob:addSimpleGambit(ai.t.TARGET, ai.c.ALWAYS, 0, ai.r.MS, ai.s.SPECIFIC, 4260, 60) -- Mix: Dark Potion (every 60s)

    -- Has a very short cooldown between uses of his healing and status-removal Mix abilities, making him the fastest trust at status-removal in the game.

    mob:SetAutoAttackEnabled(false)

    mob:addListener("WEAPONSKILL_USE", "MONBERAUX_WEAPONSKILL_USE", function(mobArg, target, wsid, tp, action)
        if wsid == 4259 then -- Mix: Dragon Shield
            --Illness and injury know no boundaries!
            xi.trust.message(mobArg, xi.trust.message_offset.SPECIAL_MOVE_1)
        end
    end)

    -- No TP for Monberaux
    mob:addListener("COMBAT_TICK", "MONBERAUX_CTICK", function(mobArg)
        mobArg:setTP(0)
    end)
end

spell_object.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DESPAWN)
end

spell_object.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DEATH)
end

return spell_object
