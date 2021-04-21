-----------------------------------
--  Area: Valkurm Dunes
-- Quest: Pirate's Chart Quest
-----------------------------------
require("scripts/globals/status")
local ID = require("scripts/zones/Valkurm_Dunes/IDs")
require("scripts/globals/fishing/fishing_accessories")
require("scripts/globals/fishing/fishing_types")
require("scripts/globals/npc_util")

local PIRATES_CHART_QUEST = {
    TreasurePools = { -- each group adds up to 100
        [1] = {
            [1] = { item_id = 688,   chance = 220 }, -- Arrowwood Log
            [2] = { item_id = 17006, chance = 140 }, -- Drill Calamary
            [3] = { item_id = 17007, chance = 140 }, -- Dwarf Pugil
            [4] = { item_id = 4484,  chance = 140 }, -- Shall Shell
            [5] = { item_id = 4580,  chance = 120 }, -- Coral Butterfly
            [6] = { item_id = 887,   chance = 120 }, -- Coral Fragment
            [7] = { item_id = 4361,  chance = 120 }, -- Nebimonite
        },
        [2] = {
            [1] = { item_id = 624,   chance = 200 }, -- Pamtam Kelp
            [2] = { item_id = 17006, chance = 140 }, -- Drill Calamary
            [3] = { item_id = 17007, chance = 140 }, -- Dwarf Pugil
            [4] = { item_id = 4484,  chance = 120 }, -- Shall Shell
            [5] = { item_id = 887,   chance = 100 }, -- Coral Fragment
            [6] = { item_id = 1587,  chance = 100 }, -- High-Quality Pugil Scales
            [7] = { item_id = 1893,  chance = 100 }, -- Salinator
            [8] = { item_id = 4288,  chance = 100 }, -- Zebra Eel
        },
        [3] = {
            [1] = { item_id = 18104, chance = 850 }, -- Fuscina
            [2] = { item_id = 1311,  chance = 120 }, -- Oxblood
            [3] = { item_id = 18020, chance = 30  }, -- Mercurial Kris
        }
    },

    initialize = function(self, zone)
        self:reset(zone)
    end,

    reset = function(self, zone)
        zone:setLocalVar("PCQActive", 0)
        zone:setLocalVar("PCQStartTime", 0)
        zone:setLocalVar("PCQPlayerCount", 0)
        zone:setLocalVar("PCQInstanceID", 0)
        zone:setLocalVar("PCQTrader", 0)
        zone:setLocalVar("PCQPlayer1", 0)
        zone:setLocalVar("PCQPlayer2", 0)
        zone:setLocalVar("PCQPlayer3", 0)
        zone:setLocalVar("PCQMsgStep", 0)
        zone:setLocalVar("PCQMobsKilled", 0)
        local qmNPC = GetNPCByID(ID.npc.QM4)
        qmNPC:timer(10000, function(npc)
            npc:setStatus(dsp.status.NORMAL)
        end)
        GetNPCByID(ID.npc.PCQ_SHIMMER):setStatus(dsp.status.NORMAL)
        GetNPCByID(ID.npc.PCQ_SHIMMER):entityAnimationPacket('efof')
        local box = GetNPCByID(ID.npc.BARNACLED_BOX)
        if box:getLocalVar('opened') == 0 then
            box:setStatus(dsp.status.DISAPPEAR)
        end
    end,

    setupParty = function(self, zone, trader)
        if trader:getPartySize(0) > 3 then
            return false
        end
        zone:setLocalVar("PCQPlayerCount", trader:getPartySize(0))
        local party = trader:getParty()
        if party ~= nil then
            local i = 1
            for _,v in ipairs(party) do
                if i < 4 then
                    if v:getZoneID() == dsp.zone.VALKURM_DUNES then
                        zone:setLocalVar("PCQPlayer" .. tostring(i), v:getID())
                        v:setLocalVar("PCQParticipant", 1)
                        v:delStatusEffectsByFlag(dsp.effectFlag.DISPELABLE)
                        if v:hasPet() then
                            local pet = v:getPet()
                            v:despawnPet()
                            if pet ~= nil then
                                DespawnMob(pet:getID())
                            end
                        end
                        if v:getFellow() ~= nil then
                            v:despawnFellow()
                        end
                        v:delStatusEffectSilent(dsp.effect.LEVEL_SYNC)
                        v:addStatusEffect(dsp.effect.LEVEL_RESTRICTION,20,0,0)
                        v:setQuestBattleID(1)
                        i = i +1
                    end
                end
            end
        end
        return true
    end,

    validateParty = function(self, zone)
        if zone:getLocalVar("PCQActive") == 0 then
            return false
        end

        local validCount = 0
        local traderID = zone:getLocalVar('PCQTrader')
        local trader = GetPlayerByID(traderID)

        if trader == nil or trader:getZoneID() ~= dsp.zone.VALKURM_DUNES then
            return false
        end

        local partySize = trader:getPartySize(0)
        local participantCount = zone:getLocalVar("PCQPlayerCount")

        if participantCount == 0 or partySize > participantCount then
            return false
        end

        local partyList = {}
        local party = trader:getParty()
        if party ~= nil then
            for _,v in ipairs(party) do
                partyList[v:getID()] = 1
            end
        end

        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if partyList[pid] == nil then
                    if player ~= nil then
                        if player:getZoneID() == dsp.zone.VALKURM_DUNES then
                            player:delStatusEffectSilent(dsp.effect.LEVEL_RESTRICTION)
                            player:setQuestBattleID(0)
                            player:setLocalVar("PCQParticipant", 0)
                            self:resetPlayerMusic(player)
                        end
                    end
                    zone:setLocalVar(var, 0)
                    zone:setLocalVar("PCQPlayerCount", math.max(0, participantCount - 1))
                else
                    if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES and
                        player:getLocalVar("PCQParticipant") == 1 then
                        validCount = validCount + 1
                    else
                        zone:setLocalVar(var, 0)
                        zone:setLocalVar("PCQPlayerCount", math.max(0, participantCount - 1))
                    end
                end
            end
        end
        if validCount >= 1 and validCount <= 3 then
            return true
        end
        return false
    end,

    restoreParty = function(self, zone)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES then
                    player:delStatusEffectSilent(dsp.effect.LEVEL_RESTRICTION)
                    player:setQuestBattleID(0)
                    player:setLocalVar("PCQParticipant", 0)
                    zone:setLocalVar(var, 0)
                end
            end
        end
    end,

    resetPlayerMusic = function(self, player)
        if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES then
            player:ChangeMusic(0, 0)
            player:ChangeMusic(1, 0)
            player:ChangeMusic(2, 101)
            player:ChangeMusic(3, 103)
        end
    end,

    startMusic = function(self, zone)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES then
                    player:ChangeMusic(0, 136)
                    player:ChangeMusic(1, 136)
                    player:ChangeMusic(2, 136)
                    player:ChangeMusic(3, 136)
                end
            end
        end
    end,

    endMusic = function(self, zone)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES then
                    self:resetPlayerMusic(player)
                end
            end
        end
    end,

    spawnNPCs = function(self)
        GetNPCByID(ID.npc.PCQ_GHOST):setStatus(dsp.status.NORMAL)
        GetNPCByID(ID.npc.PCQ_SHIMMER):entityAnimationPacket('efon')
    end,

    spawnNM = function(self, zone, target)
        local shoalWader = GetMobByID(ID.mob.HOUU_THE_SHOALWADER)
        local beachMonk = GetMobByID(ID.mob.BEACH_MONK)
        local heikeCrab = GetMobByID(ID.mob.HEIKE_CRAB)
        shoalWader:spawn()
        beachMonk:spawn()
        heikeCrab:spawn()
        shoalWader:setQuestBattleID(1)
        beachMonk:setQuestBattleID(1)
        heikeCrab:setQuestBattleID(1)
        local closestPlayer = self:getClosestPartyMember(zone, target)
        if closestPlayer ~= nil then
            shoalWader:updateClaim(closestPlayer)
            beachMonk:updateClaim(closestPlayer)
            heikeCrab:updateClaim(closestPlayer)
        else
            self:endQuest(zone, true)
            return false
        end
        return true
    end,

    despawnNM = function(self)
        DespawnMob(ID.mob.HOUU_THE_SHOALWADER)
        DespawnMob(ID.mob.BEACH_MONK)
        DespawnMob(ID.mob.HEIKE_CRAB)
    end,

    validateNM = function(self, zone)
        local shoalWader = GetMobByID(ID.mob.HOUU_THE_SHOALWADER)
        local beachMonk = GetMobByID(ID.mob.BEACH_MONK)
        local heikeCrab = GetMobByID(ID.mob.HEIKE_CRAB)
        local mobsKilled = zone:getLocalVar("PCQMobsKilled")
        if not shoalWader:isSpawned() and not beachMonk:isSpawned() and not heikeCrab:isSpawned() and mobsKilled < 3 then
            return false
        end
        return true
    end,

    despawnNPCs = function(self)
        GetNPCByID(ID.npc.PCQ_GHOST):setStatus(dsp.status.DISAPPEAR)
        GetNPCByID(ID.npc.PCQ_SHIMMER):entityAnimationPacket('efof')
    end,

    startQuest = function(self, zone, player)
        zone:setLocalVar("PCQActive", 1)
        zone:setLocalVar("PCQTrader", player:getID())
        GetNPCByID(ID.npc.QM4):setStatus(dsp.status.DISAPPEAR)
        player:confirmTrade()
        self:setupParty(zone, player)
        self:startMusic(zone)
    end,

    continueQuest = function(self, zone)
        --local qmNPC = GetNPCByID(ID.npc.QM4)
        zone:setLocalVar("PCQStartTime", os.time())
        zone:setLocalVar("PCQMsgStep", 1)
        zone:setProcessUpdates(true)
        self:spawnNPCs()
    end,

    messageParty = function(self, zone, npc, textId)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES and
                    player:getLocalVar("PCQParticipant") == 1 then
                    player:showText(npc, textId)
                end
            end
        end
    end,

    getClosestPartyMember = function(self, zone, trader)
        local closestPlayer
        local lastDistance = 0
        local qmNPC = GetNPCByID(ID.npc.QM4)
        if trader ~= nil and trader:checkDistance(qmNPC) < 30 then
            return trader
        end
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES then
                    local currentDistance = player:checkDistance(qmNPC)
                    if currentDistance < 30 then
                        if lastDistance == 0 or currentDistance < lastDistance then
                            lastDistance = currentDistance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        return closestPlayer
    end,

    messagePartySpecial = function(self, zone, textId)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES and
                    player:getLocalVar("PCQParticipant") == 1 then
                    player:messageSpecial(textId)
                end
            end
        end
    end,

    checkDistances = function(self, zone)
        for i = 1, 3 do
            local var = "PCQPlayer" .. tostring(i)
            local pid = zone:getLocalVar(var)
            if pid > 0 then
                local player = GetPlayerByID(pid)
                local qmNPC = GetNPCByID(ID.npc.QM4)
                if player ~= nil and player:getZoneID() == dsp.zone.VALKURM_DUNES and
                    player:getLocalVar("PCQParticipant") == 1 and player:checkDistance(qmNPC) >= 11 then
                    local lastWarning = player:getLocalVar("lastWarning")
                    if os.time() - lastWarning > 6 then
                        player:showText(qmNPC, ID.text.pirates_chart_quest.NO_LONGER_FEEL_CHILL)
                        player:setLocalVar("lastWarning", os.time())
                    end
                end
            end
        end
    end,

    questUpdate = function(self, zone)
        local startTime = zone:getLocalVar('PCQStartTime')
        local timeRemaining = (600 + startTime) - os.time()
        local traderID = zone:getLocalVar('PCQTrader')
        local trader = GetPlayerByID(traderID)

        if trader == nil or trader:getZoneID() ~= dsp.zone.VALKURM_DUNES then
            self:endQuest(zone, false)
            return false
        end

        if startTime == 0 or zone:getLocalVar("PCQActive") == 0 then
            self:endQuest(zone, false)
            return false
        end

        if timeRemaining == 0 then
            self:endQuest(zone, true)
            return false
        end

        local step = zone:getLocalVar("PCQMsgStep")

        if step == 0 or step > 8 then
            self:endQuest(zone, false)
            return false
        end

        if timeRemaining > 0 and self:validateParty(zone) then
            local qmNPC = GetNPCByID(ID.npc.QM4)
            local ghostNPC = GetNPCByID(ID.npc.PCQ_GHOST)
            local timeSinceStart = os.time() - startTime

            if trader ~= nil and step < 8 then
                if step == 1 and timeSinceStart > 2 then
                    zone:setLocalVar("PCQMsgStep", 2)
                    ghostNPC:sendEntityEmote(ghostNPC, dsp.emote.PANIC, dsp.emoteMode.MOTION)
                    self:messageParty(zone, qmNPC, ID.text.pirates_chart_quest.RIGHT_OVER_THERE)
                elseif step == 2 and timeSinceStart > 12 then
                    zone:setLocalVar("PCQMsgStep", 3)
                    ghostNPC:sendEntityEmote(ghostNPC, dsp.emote.PANIC, dsp.emoteMode.MOTION)
                elseif step == 3 and timeSinceStart > 22 then
                    zone:setLocalVar("PCQMsgStep", 4)
                    ghostNPC:sendEntityEmote(ghostNPC, dsp.emote.PANIC, dsp.emoteMode.MOTION)
                    self:messageParty(zone, qmNPC, ID.text.pirates_chart_quest.AHHH_HURRY_UP)
                elseif step == 4 and timeSinceStart > 32 then
                    zone:setLocalVar("PCQMsgStep", 5)
                    ghostNPC:sendEntityEmote(ghostNPC, dsp.emote.PANIC, dsp.emoteMode.MOTION)
                    self:messageParty(zone, qmNPC, ID.text.pirates_chart_quest.ITS_COMING_FOR_US)
                elseif step == 5 and timeSinceStart > 42 then
                    zone:setLocalVar("PCQMsgStep", 6)
                    ghostNPC:sendEntityEmote(ghostNPC, dsp.emote.PANIC, dsp.emoteMode.MOTION)
                    self:messageParty(zone, qmNPC, ID.text.pirates_chart_quest.IT_CANTARU_BE)
                elseif step == 6 and timeSinceStart > 47 then
                    zone:setLocalVar("PCQMsgStep", 7)
                    self:messageParty(zone, qmNPC, ID.text.pirates_chart_quest.NOOOOOO)
                    self:messagePartySpecial(zone, ID.text.pirates_chart_quest.NPC_DISAPPEARS)
                    ghostNPC:entityAnimationPacket("dead")
                elseif step == 7 and timeSinceStart > 50 then
                    zone:setLocalVar("PCQMsgStep", 8)
                    ghostNPC:setStatus(dsp.status.DISAPPEAR)
                    return self:spawnNM(zone, trader)
                end
                self:checkDistances(zone)
            end
            if step == 8 and not self:validateNM(zone) then
                self:endQuest(zone, true)
                return false
            end
        end
        return true
    end,

    winQuest = function(self, zone, player)
        self:endQuest(zone, false)
    end,

    endQuest = function(self, zone, timeout)
        if zone:getLocalVar("PCQActive") > 0 then
            if timeout then
                self:messagePartySpecial(zone, ID.text.pirates_chart_quest.TOO_MUCH_TIME_PASSED)
            end
            zone:setProcessUpdates(false)
            self:endMusic(zone)
            self:despawnNM()
            self:despawnNPCs()
            self:restoreParty(zone)
            self:reset(zone)
        end
    end,

    questActive = function(self, zone, player)
        if zone:getLocalVar("PCQActive") > 0 and player:getLocalVar("PCQParticipant") > 0 then
            return true
        end
        return false
    end,

    handleTrade = function(self, player, npc, trade)
        if npcUtil.tradeHasExactly(trade, 1874) then
            local zone = npc:getZone()
            local questActive = zone:getLocalVar('PCQActive')
            if questActive == 0 then
                if player:hasStatusEffect(dsp.effect.LEVEL_RESTRICTION) then
                    player:messageSpecial(ID.text.pirates_chart_quest.NOTHING_HAPPENS)
                end
                if player:inAlliance() then
                    player:messageSpecial(ID.text.pirates_chart_quest.MUST_DISSOLVE_ALLIANCE)
                    return
                end
                if player:getPartySize(0) > 3 then
                    player:messageSpecial(ID.text.pirates_chart_quest.MORE_THAN_THREE_PARTY, 3, 0)
                    return
                end
                player:messageSpecial(ID.text.pirates_chart_quest.RETURN_PIRATES_CHART, 1874)
                player:startEvent(14)
            end
        end
    end,

    handleTrigger = function(self, player, npc)
        player:messageSpecial(ID.text.pirates_chart_quest.MONSTERS_KILLED_ADVENTURERS)
    end,

    sanityCheck = function(self, zone, player)
        if zone:getLocalVar("PCQMsgStep") == 0 then
            self:endQuest(zone, false)
        end
    end,

    handleEventUpdate = function(self, player,csid,option)
        local zone = player:getZone()
        if csid == 14 then -- Pirate's Chart Quest
            if option == 0 then -- accepted quest
                if zone:getLocalVar('PCQActive') == 0 then
                    self:startQuest(zone, player)
                    player:timer(30000, function(player)
                        self:sanityCheck(zone, player)
                    end)
                else
                    if player:getLocalVar("PCQParticipant") == 0 then
                        player:release()
                    end
                end
            end
        end
    end,

    handleEventFinish = function(self, player, csid, option)
        local zone = player:getZone()
        if csid == 14 then -- Pirate's Chart Quest
            if option == 0 then -- initial dialogue completed
                if zone:getLocalVar('PCQActive') == 1 then
                    self:continueQuest(zone, player)
                else
                    self:endQuest(zone, false)
                end
            end
        end
    end,

    getCatchList = function(self)
        local flags = fishing.poolFlag.FISHPOOL_NONE
        local catchlist = {}

        flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_ITEM)
        catchlist['items'] = {
            [1] = { item_id = 5329, rarity = 1000 },
            [2] = { item_id = 5330, rarity = 1000 }
        }

        flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_QUEST)
        flags = bit.bor(flags, fishing.poolFlag.FISHPOOL_WEIGHTS)

        catchlist['fish_weight'] = 0
        catchlist['item_weight'] = 1000
        catchlist['mob_weight'] = 0
        catchlist['chest_weight'] = 0
        catchlist['nocatch_weight'] = 0

        return flags, catchlist
    end,

    pickTreasure = function(self, poolNumber)
        local aggregator = 0
        local pool = self.TreasurePools[poolNumber]
        local randomizer = math.random(1,1000)
        for item = 1, #pool do
            aggregator = aggregator + pool[item].chance
            if randomizer <= aggregator then
                return pool[item].item_id
            end
        end
    end,

    openChest = function(self, player, npc)
        local zone = npc:getZone()
        self:winQuest(zone, player)
        for i = 1, 3 do
            local treasure = self:pickTreasure(i)
            player:addTreasure(treasure, npc)
        end
        player:addTreasure(fishing.rings.ALBATROSS, npc)
    end
}

return PIRATES_CHART_QUEST
