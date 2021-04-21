-----------------------------------
--  Area: Buburimu Peninsula
-- Quest: Brigand's Chart Quest
-----------------------------------
require("scripts/globals/status")
local ID = require("scripts/zones/Buburimu_Peninsula/IDs")
require("scripts/globals/fishing/fishing_accessories")
require("scripts/globals/fishing/fishing_types")
require("scripts/globals/npc_util")

local BRIGANDS_CHART_QUEST = {
    NotableLoot = {
        [1] = { item_id = 17007 }, -- Dwarf Pugil
        [2] = { item_id =   190 }, -- Lines and Space
        [3] = { item_id =   105 }, -- Sky Pot
        [4] = { item_id =    91 }, -- Blue Pitcher
        [5] = { item_id =   220 }  -- Wooden Flowerpot
    },

    OtherLoot = {
        [1]  = { item_id =  4403 }, -- Yellow Globe
        [2]  = { item_id =   656 }, -- Beastcoin
        [3]  = { item_id =   750 }, -- Silver Beastcoin
        [4]  = { item_id =   748 }, -- Gold Beastcoin
        [5]  = { item_id =   750 }, -- Silver Beastcoin
        [6]  = { item_id =   749 }, -- Mythril Beastcoin
        [7]  = { item_id =   751 }, -- Platinum Beastcoin
        [8]  = { item_id =  1455 }, -- One Byne Bill
        [9]  = { item_id =  1452 }, -- Ordelle Bronzepiece
        [10] = { item_id =  1449 }, -- Tukuku Whiteshell
        [11] = { item_id = 16537 }, -- Mythril Sword
        [12] = { item_id = 12522 }, -- Rusty Cap
        [13] = { item_id = 14117 }, -- Rusty Leggings
        [14] = { item_id = 14242 }, -- Rusty Subligar
        [15] = { item_id = 65535 }  -- 500 gil
    },

    chestSpawnDegrees = {
        [ID.npc.JADE_ETUI[1]] =   0,
        [ID.npc.JADE_ETUI[2]] =  16,
        [ID.npc.JADE_ETUI[3]] = -16,
        [ID.npc.JADE_ETUI[4]] =  32,
        [ID.npc.JADE_ETUI[5]] = -32
    },

    initialize = function(self, zone)
        self:reset(zone)
    end,

    reset = function(self, zone)
        zone:setLocalVar("BCQActive", 0)
        zone:setLocalVar("BCQStartTime", 0)
        zone:setLocalVar("BCQPlayer", 0)
        zone:setLocalVar("BCQMsgStep", 0)
        zone:setLocalVar("BCQChestsOpened", 0)
        zone:setLocalVar("BCQPenguinObtained", 0)
        GetNPCByID(ID.npc.QM1):setStatus(dsp.status.NORMAL)
        GetNPCByID(ID.npc.BCQ_SHIMMER):setStatus(dsp.status.NORMAL)
        GetNPCByID(ID.npc.BCQ_SHIMMER):entityAnimationPacket('efof')
        GetMobByID(ID.mob.PUFFER_PUGIL):setLocalVar('catchable', 0)
        for i = 1, #ID.npc.JADE_ETUI do
            local npc = GetNPCByID(ID.npc.JADE_ETUI[i])
            if npc:getLocalVar('opened') == 0 then
                npc:setStatus(dsp.status.DISAPPEAR)
                npc:setLocalVar('catchable', 0)
            end
        end
    end,

    questActive = function(self, zone, player)
        if zone:getLocalVar("BCQActive") > 0 and zone:getLocalVar("BCQPlayer") == player:getID() then
            return true
        end
        return false
    end,

    handleTrade = function(self, player, npc, trade)
        if npcUtil.tradeHasExactly(trade, 1873) then
            local zone = npc:getZone()
            local questActive = zone:getLocalVar('BCQActive')
            if questActive == 0 then
                player:messageSpecial(ID.text.brigands_chart_quest.RETURN_CHART, 1873)
                player:startEvent(902)
            end
        end
    end,

    handleTrigger = function(self, player, npc)
        player:messageSpecial(ID.text.brigands_chart_quest.LONG_AGO)
    end,

    handleEventUpdate = function(self, player,csid,option)
        local zone = player:getZone()
        if csid == 902 then -- Brigand's Chart Quest
            if option == 0 then -- accepted quest
                if zone:getLocalVar('BCQActive') == 0 then
                    self:startQuest(zone, player)
                else
                    player:release()
                end
            end
        end
    end,

    handleEventFinish = function(self, player, csid, option)
        local zone = player:getZone()
        if csid == 902 then -- Brigand's Chart Quest
            if option == 0 then -- initial dialogue completed
                self:continueQuest(zone, player)
            end
        end
    end,

    startMusic = function(self, player)
        player:ChangeMusic(0, 136)
        player:ChangeMusic(1, 136)
        player:ChangeMusic(2, 136)
        player:ChangeMusic(3, 136)
    end,

    endMusic = function(self, player)
        player:ChangeMusic(0, 0)
        player:ChangeMusic(1, 0)
        player:ChangeMusic(2, 101)
        player:ChangeMusic(3, 103)
    end,

    startQuest = function(self, zone, player)
        GetNPCByID(ID.npc.QM1):setStatus(dsp.status.DISAPPEAR)
        player:confirmTrade()
        player:delStatusEffectSilent(dsp.effect.LEVEL_SYNC)
        player:addStatusEffect(dsp.effect.LEVEL_RESTRICTION,20,0,0)
        player:setLocalVar("QuestBattleID", 1)
        zone:setLocalVar("BCQActive", 1)
        zone:setLocalVar("BCQPlayer", player:getID())
        self:startMusic(player)
        GetMobByID(ID.mob.PUFFER_PUGIL):setLocalVar('catchable', 1)
        for i = 1, #ID.npc.JADE_ETUI do
            GetNPCByID(ID.npc.JADE_ETUI[i]):setStatus(dsp.status.DISAPPEAR)
            GetNPCByID(ID.npc.JADE_ETUI[i]):setLocalVar('catchable', 1)
        end
    end,

    spawnNPCs = function(self)
        GetNPCByID(ID.npc.BCQ_GHOST):setStatus(dsp.status.NORMAL)
        GetNPCByID(ID.npc.BCQ_SHIMMER):entityAnimationPacket('efon')
    end,

    despawnNPCs = function(self)
        GetNPCByID(ID.npc.BCQ_GHOST):setStatus(dsp.status.DISAPPEAR)
        GetNPCByID(ID.npc.BCQ_SHIMMER):entityAnimationPacket('efof')
    end,

    continueQuest = function(self, zone, player)
        local qmNPC = GetNPCByID(ID.npc.QM1)
        zone:setLocalVar("BCQStartTime", os.time())
        zone:setLocalVar("BCQMsgStep", 0)
        zone:setProcessUpdates(true)
        self:spawnNPCs()
        self:showNextMessage(zone, player, qmNPC)
    end,

    showNextMessage = function(self, zone, player, npc)
        local step = zone:getLocalVar("BCQMsgStep")
        if step < 7 then
            local msgId = ID.text.brigands_chart_quest.MY_PENGUIN_RING + step
            zone:setLocalVar("BCQMsgStep", step + 1)
            player:showText(npc, msgId, fishing.rings.PENGUIN)
        end
    end,

    questTimeRemaining = function(self, zone)
        local startTime = zone:getLocalVar("BCQStartTime")
        local timeSinceStart = (os.time() - startTime)
        local timeRemaining = 180 - timeSinceStart
        return timeRemaining
    end,

    questUpdate = function(self, zone)
        if zone:getLocalVar("BCQActive") == 0 then
            self:endQuest(zone, nil, false)
            return false
        end
        local step = zone:getLocalVar("BCQMsgStep")
        if step == 0 then
            return false
        end
        local playerID = zone:getLocalVar('BCQPlayer')
        local player = GetPlayerByID(playerID)
        local timeRemaining = self:questTimeRemaining(zone)
        local qmNPC = GetNPCByID(ID.npc.QM1)

        if timeRemaining > 0 and player ~= nil then
            if step < 6 then
                if (step == 1 and timeRemaining <= 121) or (step == 2 and timeRemaining <= 91) or
                    (step == 3 and timeRemaining <= 61) or (step == 4 and timeRemaining <= 31) or
                    (step == 5 and timeRemaining <= 11) then
                    self:showNextMessage(zone, player, qmNPC)
                    return true
                end
            end
        else
            self:endQuest(zone, player, true)
        end
        return false
    end,

    winQuest = function(self, zone, player)
        local qmNPC = GetNPCByID(ID.npc.QM1)
        self:endQuest(zone, player, false)
        player:showText(qmNPC, ID.text.brigands_chart_quest.ITS_BACK_NOW)
    end,

    endQuest = function(self, zone, player, timeout)
        if player ~= nil then
            player:delStatusEffectSilent(dsp.effect.LEVEL_RESTRICTION)
            player:setLocalVar("QuestBattleID", 0)
            if timeout then
                local qmNPC = GetNPCByID(ID.npc.QM1)
                player:showText(qmNPC, ID.text.brigands_chart_quest.IT_CANT_BE)
            end
            self:endMusic(player)
        end
        zone:setProcessUpdates(false)
        self:despawnNPCs()
        self:reset(zone)
    end,

    incChestsOpened = function(self, zone)
        local chestsOpened = self:getChestsOpened(zone)
        zone:setLocalVar("BCQChestsOpened", chestsOpened + 1)
    end,

    getChestsOpened = function(self, zone)
        return zone:getLocalVar("BCQChestsOpened")
    end,

    setPenguinObtained = function(self, zone)
        zone:setLocalVar("BCQPenguinObtained", 1)
    end,

    isPenguinObtained = function(self, zone)
        return zone:getLocalVar("BCQPenguinObtained") > 0
    end,

    getAvailableJadeEtui = function(self)
        for i = 1, #ID.npc.JADE_ETUI do
            local chest = GetNPCByID(ID.npc.JADE_ETUI[i])
            if chest:getStatus() == dsp.status.DISAPPEAR then
                return ID.npc.JADE_ETUI[i]
            end
        end
        return 0
    end,

    pufferPugilAvailable = function(self)
        local puffer = GetMobByID(ID.mob.PUFFER_PUGIL)
        local pufferSpawned = puffer:isSpawned()
        local catchable = puffer:getLocalVar('catchable') == 1
        return (pufferSpawned == false and catchable)
    end,

    pickTreasure = function(self, zone, player, npc)
        local chestCount = self:getChestsOpened(zone)
        local gotPenguin = false
        if self:isPenguinObtained(zone) == false and chestCount >= 4 then
            local ringChance = 30
            if chestCount >= 5 then
                ringChance = 60
            end
            if math.random(1,100) < ringChance then
                self:setPenguinObtained(zone)
                gotPenguin = true
                player:addTreasure(fishing.rings.PENGUIN, npc)
            end
        end
        local randomizer = math.random(1, 100)
        if randomizer <= 40 then -- choose notable loot
            local notableRandom = math.random(1, #self.NotableLoot)
            return self.NotableLoot[notableRandom]
        else                     -- choose random loot
            local otherRandom = math.random(1, #self.OtherLoot)
            return self.OtherLoot[otherRandom]
        end

    end,

    openChest = function(self, player, npc)
        local zone = player:getZone()
        self:incChestsOpened(zone)
        local treasure = self:pickTreasure(zone, player, npc)
        if treasure == 65535 then    -- gil
            npcUtil.giveGil(player, 500)
        elseif treasure == 4403 then -- yellow globes (1-3)
            local count = math.random(1, 3)
            for _ = 1, count do
                player:addTreasure(treasure.item_id, npc)
            end
        else
            player:addTreasure(treasure.item_id, npc)
        end
        if self:isPenguinObtained(zone) then
            self:winQuest(zone, player, false)
        end
    end,

    getCatchList = function(self)
        local flags = fishing.poolFlag.FISHPOOL_NONE
        local catchlist = {}
        local gotChest = false
        local gotPugil = false
        local chest = self:getAvailableJadeEtui()
        local pufferAvailable = self:pufferPugilAvailable()
        local mobWeight = 0
        local chestWeight = 0
        local noCatchWeight = 0
        if chest > 0 then
            local chestRarity = 800
            if not pufferAvailable then
                chestRarity = 1000
            end
            catchlist['chests'] = { [1] = { npc_id = chest, rarity = chestRarity, angle = self.chestSpawnDegrees[chest] } }
            gotChest = true
            flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_CHEST)
            chestWeight = 800
        end
        if pufferAvailable then
            local pugRarity = 200
            if not gotChest then
                pugRarity = 1000
            end
            catchlist['mobs'] = { [1] = { mob_id = ID.mob.PUFFER_PUGIL, rarity = pugRarity }}
            gotPugil = true
            flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_MOB)
            mobWeight = 200
        end

        flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_QUEST)
        flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_WEIGHTS)

        if not chest and not pufferAvailable then
            noCatchWeight = 1000
        end

        catchlist['fish_weight'] = 0
        catchlist['item_weight'] = 0
        catchlist['mob_weight'] = mobWeight
        catchlist['chest_weight'] = chestWeight
        catchlist['nocatch_weight'] = noCatchWeight
        return flags, catchlist
    end
}

return BRIGANDS_CHART_QUEST
