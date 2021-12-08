-----------------------------------
-- Below the Arks
-- Promathia 1-2
-----------------------------------
-- Pherimociel : !pos -31.627 1.002 67.956 243
-- Rainhard    : !pos -2.397 -5.999 68.749 243
-- Harith      : !pos -4.349 1 134.014 243
--
-- Shattered Telepoint (LaTheine/Holla) : !pos 334 19 -60 102
-- Shattered Telepoint (Konschtat/Dem)  : !pos 135 19 220 108
-- Shattered Telepoint (Tahrongi/Mea)   : !pos 179 35 255 117
-----------------------------------
require('scripts/globals/interaction/mission')
require('scripts/globals/keyitems')
require('scripts/globals/missions')
require('scripts/settings/main')
require('scripts/globals/zone')
-----------------------------------

local mission = Mission:new(xi.mission.log_id.COP, xi.mission.id.cop.BELOW_THE_ARKS)

mission.reward =
{
    nextMission = { xi.mission.log_id.COP, xi.mission.id.cop.THE_MOTHERCRYSTALS },
}

mission.sections =
{
    -- 1. Head to Ru'Lude Gardens and speak with Pherimociel (G-6) for a cutscene that begins this mission.
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == xi.mission.id.cop.BELOW_THE_ARKS and missionStatus == 0
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Pherimociel'] =
            {
                onTrigger = function(player, npc)
                    return mission:progressEvent(24)
                end,
            },

            onEventFinish =
            {
                [24] = function(player, csid, option, npc)
                    player:setMissionStatus(mission.areaId, 1)
                    player:setCharVar("FirstPromyvionHolla", 1)
                    player:setCharVar("FirstPromyvionMea", 1)
                    player:setCharVar("FirstPromyvionDem", 1)
                end,
            },
        },
    },

    -- 2. You are now able to enter any of the three Promyvion areas.
    --
    --    They are accessed by examining the Shattered Telepoint at the
    --    crags in:
    --    Konschtat Highlands (Promyvion - Dem),
    --    Tahrongi Canyon (Promyvion - Mea), and
    --    La Theine Plateau (Promyvion - Holla).
    --
    --    After examining the Shattered Telepoint and entering the
    --    Hall of Transference, click on the Large Apparatus to your
    --    left to enter Promyvion if this is your first time here.
    --
    --    If not, you can enter via the Cermet gate in the center.
    --    The 3 Promyvions can be completed in any order.
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == xi.mission.id.cop.BELOW_THE_ARKS and missionStatus == 1
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Pherimociel'] =
            {
                onTrigger = function(player, npc)
                    return mission:event(25)
                end,
            },

            -- (Optional)
            ['Rainhard'] =
            {
                onTrigger = mission:event(34),
            }

            -- (Optional)
            ['Harith'] =
            {
                onTrigger = mission:event(113),
            }
        },

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(202, 0, 0, 1),
            }

            onEventFinish =
            {
                [202] = function(player, csid, option, npc)
                    if option == 0 then
                        player:setPos(-266.76, -0.635, 280.058, 0, 14) -- To Hall of Transference {R}
                    end
                end,
            },
        },

        [xi.zone.KONSCHTAT_HIGHLANDS] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(913, 0, 0, 1),
            }

            onEventFinish =
            {
                [913] = function(player, csid, option, npc)
                    if option == 0 then
                        player:setPos(-267.194, -40.634, -280.019, 0, 14) -- To Hall of Transference {R}
                    end
                end,
            },
        },

        [xi.zone.TAHRONGI_CANYON] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(913, 0, 0, 1),
            }

            onEventFinish =
            {
                [913] = function(player, csid, option, npc)
                    if option == 0 then
                        player:setPos(280.066, -80.635, -67.096, 191, 14) -- To Hall of Transference {R}
                    end
                end,
            },
        },

        [xi.zone.HALL_OF_TRANSFERENCE] =
        {
            -- Large Apparatus (Left) - Holla
            ['_0e3'] =
            {
                onTrigger = mission:progressEvent(160),
            }

            -- Large Apparatus (Left) - Dem
            ['_0e5'] =
            {
                onTrigger = mission:progressEvent(160),
            }

            -- Large Apparatus (Left) - Mea
            ['_0e7'] =
            {
                onTrigger = mission:progressEvent(160),
            }

            onEventFinish =
            {
                [160] = function(player, csid, option, npc)
                    local name = npc:getName()
                    if name == '_0e3' then
                        player:setPos(92.033, 0, 80.380, 255, 16) -- To Promyvion Holla {R}
                    elseif name == '_0e5' then
                        player:setPos(185.891, 0, -52.331, 128, 18) -- To Promyvion Dem {R}
                    elseif name == '_0e7' then
                        player:setPos(-93.268, 0, 170.749, 162, 20) -- To Promyvion Mea {R}
                    end
                end,
            },
        },
    },
}

return mission
