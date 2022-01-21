-----------------------------------
-- Trust: Monberaux
-- TODO: We are using the model with white hair, it should be black!
-----------------------------------
require("scripts/globals/trust")
-----------------------------------
local spell_object = {}

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

    mob:addListener("WEAPONSKILL_USE", "MONBERAUX_WEAPONSKILL_USE", function(mobArg, target, wsid, tp, action)
        if wsid == 4259 then -- Mix: Dragon Shield
            --Illness and injury know no boundaries!
            xi.trust.message(mobArg, xi.trust.message_offset.SPECIAL_MOVE_1)
        end
    end)

    -- Tends to be particular about which potions to use. Seems to favor healing for just the
    -- right amount of HP instead of defaulting to the highest-rank potion.
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 700, ai.r.MS, ai.s.SPECIFIC, 4237) -- Mix: Max Potion
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 500, ai.r.MS, ai.s.SPECIFIC, 4236) -- Max Potion
    mob:addSimpleGambit(ai.t.PARTY, ai.c.HP_MISSING, 250, ai.r.MS, ai.s.SPECIFIC, 4235) -- Hyper Potion

    -- Seems to only use Elemental Power with an offensive caster in the group.

    -- Uses Ethers when party members are ~50% MP.

    -- Uses Life Water when multiple party members hit yellow HP.

    --Except for the occasional application of Dark Potion, does not attack or cast spells.

    -- Has a very short cooldown between uses of his healing and status-removal Mix abilities, making him the fastest trust at status-removal in the game.

    mob:SetAutoAttackEnabled(false)

    -- TODO: Does Monberaux get TP when he is hit?
end

spell_object.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DESPAWN)
end

spell_object.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DEATH)
end

return spell_object
