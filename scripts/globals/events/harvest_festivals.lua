-----------------------------------
-- Harvest Festivals
-----------------------------------
require("scripts/settings/main")
require("scripts/globals/status")
require("scripts/globals/utils")
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.harvest_festival = {}

xi.events.harvest_festival.isEnabled = function()
    local month = tonumber(os.date("%m"))
    local day = tonumber(os.date("%d"))

    if
        ((month == 10 and day >= 20) or
        (month == 11 and day == 1) or
        xi.settings.HALLOWEEN_YEAR_ROUND == 1) and
        xi.settings.HALLOWEEN_2005 == 1
    then
        return true
    end

    return false
end

local function halloweenItemsCheck(player)
    local rewardItemID = 0

    local rewardInfo =
    {
        { xi.items.PUMPKIN_HEAD,    xi.items.HORROR_HEAD,    xi.slot.HEAD },
        { xi.items.PUMPKIN_HEAD_II, xi.items.HORROR_HEAD_II, xi.slot.HEAD },
        { xi.items.TRICK_STAFF,     xi.items.TREAT_STAFF,    xi.slot.MAIN },
        { xi.items.TRICK_STAFF_II,  xi.items.TREAT_STAFF_II, xi.slot.MAIN },
    }

    -- Handle HQ Upgrade Items
    for _, rewardData in ipairs(rewardInfo) do
        if
            player:getEquipID(rewardData[3]) == rewardData[1] and
            not player:findItem(rewardData[2])
        then
            rewardItemID = rewardData[2]
            break
        end
    end

    -- Handle NQ Items, and ensure player does not already have one
    local cnt = #rewardInfo

    while cnt ~= 0 do
        local selectedItemID = rewardInfo[math.random(1, #rewardInfo)][1]

        if not player:findItem(selectedItemID) then
            rewardItemID = selectedItemID
            cnt = 0
        else
            table.remove(rewardInfo, selectedItemID)
            cnt = cnt - 1
        end
    end

    return rewardItemID
end

xi.events.harvest_festival.onHarvestFestivalTrade = function(player, trade, npc)
    local zone = player:getZoneName()
    local ID = zones[player:getZoneID()]

    local item = trade:getItemId()
    -----------------------------------
    -- 2005 edition
    -----------------------------------
    if xi.events.harvest_festival.isHalloweenEnabled() then
        -----------------------------------
        -- Treats allowed
        -----------------------------------
        local treats_table =
        {
            4510, -- Acorn Cookie
            5646, -- Bloody Chocolate
            4496, -- Bubble Chocolate
            4397, -- Cinna-cookie
            4394, -- Ginger Cookie
            4495, -- Goblin Chocolate
            4413, -- Apple Pie
            4488, -- Jack-o'-Pie
            4421, -- Melon Pie
            4563, -- Pamama Tart
            4446, -- Pumpkin Pie
            4414, -- Rolanberry Pie
            4406, -- Baked Apple
            5729, -- Bavarois
            5745, -- Cherry Bavarois
            5653, -- Cherry Muffin
            5655, -- Coffee Muffin
            5718, -- Cream Puff
            5144, -- Crimson Jelly
            5681, -- Cupid Chocolate
            5672, -- Dried Berry
            5567, -- Dried Date
            4556, -- Icecap Rolanberry
            5614, -- Konigskuchen
            5230, -- Love Chocolate
            4502, -- Marron Glace
            4393, -- Orange Kuchen
            5147, -- Snoll Gelato
            4270, -- Sweet Rice Cake
            5645, -- Witch Nougat
            5552, -- Black Pudding  --safe
            5550, -- Buche au Chocolat -- safe @ 43 items
            5616, -- Lebkuchen House --breaks
            5633, -- Chocolate Cake
            5542, -- Gateau aux Fraises
            5572, -- Irmik Helvasi
            5625, -- Maple Cake
            5559, -- Mille Feuille
            5557, -- Mont Blanc
            5629, -- Orange Cake
            5631, -- Pumpkin Cake
            5577, -- Sutlac
            5627, -- Yogurt Cake
        }

        for itemInList = 1, #treats_table  do
            if item == treats_table[itemInList] then
                local itemReward = halloweenItemsCheck(player)
                local varName = "harvestFestTreats"
                local harvestFestTreats
                if itemInList < 32 then -- The size of the list is too big for int 32 used that stores the bit mask, as such there are two lists

                    harvestFestTreats = player:getCharVar(varName)
                else

                    varName = "harvestFestTreats2"
                    harvestFestTreats = player:getCharVar(varName) --  this is the second list
                    itemInList = itemInList - 32
                end

                local AlreadyTradedChk = utils.mask.getBit(harvestFestTreats, itemInList)
                if
                    itemReward ~= 0 and
                    player:getFreeSlotsCount() >= 1 and
                    math.random(1, 3) < 2
                then -- Math.random added so you have 33% chance on getting item

                    player:messageSpecial(ID.text.HERE_TAKE_THIS)
                    player:addItem(itemReward)
                    player:messageSpecial(ID.text.ITEM_OBTAINED, itemReward)

                elseif player:canUseMisc(xi.zoneMisc.COSTUME) and not AlreadyTradedChk then
                -- Other neat looking halloween type costumes
                -- two dragon skins: @420/421
                -- @422 dancing weapon
                -- @ 433/432 golem
                -- 265 dark eye, 266 Giant version
                -- 290 dark bombs
                -- 301 dark mandy
                -- 313 black spiders
                -- 488 gob
                -- 531 - 548 shade
                -- 564/579 skele

                    -- Possible costume values:
                    local Yagudo = math.random(580, 607)
                    local Quadav = math.random(644, 671)
                    local Shade = math.random(535, 538)
                    local Orc = math.random(612, 639)
                    local Ghost = 368
                    local Hound = 365
                    local Skeleton = 564
                    local Dark_Stalker = math.random(531, 534)

                    local halloween_costume_list = {Quadav, Orc, Yagudo, Shade, Ghost, Hound, Skeleton, Dark_Stalker}

                    local costumePicked = halloween_costume_list[math.random(1, #halloween_costume_list)] -- will randomly pick one of the costumes in the list
                    player:addStatusEffect(xi.effect.COSTUME, costumePicked, 0, 3600)

                    -- pitchForkCostumeList defines the special costumes per zone that can trigger the pitch fork requirement
                    -- zone, costumeID
                    local pitchForkCostumeList =
                    {
                        234, Shade, Skeleton, -- Bastok mines
                        235, Hound, Ghost,    -- Bastok Markets
                        230, Ghost, Skeleton, -- Southern Sandoria
                        231, Hound, Skeleton, -- Northern Sandoria
                        241, Ghost, Shade,    -- Windurst Woods
                        238, Shade, Hound     -- Windurst Woods
                    }

                    for zi = 1, #pitchForkCostumeList, 3 do
                        if
                            zone == pitchForkCostumeList[zi] and
                            (costumePicked == pitchForkCostumeList[zi + 1] or
                            zone == pitchForkCostumeList[zi] and
                            costumePicked == pitchForkCostumeList[zi + 2])
                        then -- Gives special hint for pitch fork costume
                            player:messageSpecial(ID.text.IF_YOU_WEAR_THIS)
                        elseif zi == 16 then
                            player:messageSpecial(ID.text.THANK_YOU_TREAT)
                        end
                    end
                else
                    player:messageSpecial(ID.text.THANK_YOU)
                end

                if not AlreadyTradedChk then
                    player:setCharVar(varName, utils.mask.setBit(harvestFestTreats, itemInList, true))
                end

                player:tradeComplete()
                break
            end
        end
    end
end

function applyHalloweenNpcCostumes(zoneid)
    if not xi.events.harvest_festival.isEnabled() then
        return
    end

    local skins = zones[zoneid].npc.HALLOWEEN_SKINS
    if skins then
        for id, skin in pairs(skins) do
            local npc = GetNPCByID(id)

            if npc then
                npc:changeSkin(skin)
            end
        end
    end
end
