-----------------------------------
-- Area: Selbina
--  NPC: Chenon
-- Type: Fish Ranking NPC
-- !pos -13.472 -8.287 9.497 248
-----------------------------------
require("scripts/globals/titles")
local ID = require("scripts/zones/Selbina/IDs")
-----------------------------------
local entity = {}

--                            1st, 2nd, 3rd, 4th-10th
local RankPrizeAnimations = { 311, 312, 313, 314 }

function SetRankingTitle(player, place)
    if place == 1 then
        player:playAnimation(RankPrizeAnimations[1],0)
        player:setTitle(xi.title.GOLD_HOOK)
    elseif place == 2 then
        player:playAnimation(RankPrizeAnimations[2],0)
        player:setTitle(xi.title.MYTHRIL_HOOK)
    elseif place == 3 then
        player:playAnimation(RankPrizeAnimations[3],0)
        player:setTitle(xi.title.SILVER_HOOK)
    elseif place >= 4 and place <= 10 then
        player:playAnimation(RankPrizeAnimations[4],0)
        player:setTitle(xi.title.COPPER_HOOK)
    end
end

entity.onTrade = function(player, npc, trade)
    local item = trade:getItem(0)
    local info = GetFishRankingInformation()

    local csid = 10007

    if not info.enabled then
        csid = 10010
    end

    if info.period == 2 and item ~= nil and item:isFish() and item:getID() == info.currentFishId and trade:getItemCount() == 1 then
        local score = 0
        local prevscore = player:getCurrentFishRankingScore()
        local length = item:getLength()
        local weight = item:getWeight()

        local lw = bit.bor(bit.band(weight, 0xffff), bit.lshift(bit.band(length, 0xffff), 16))

        if item:isRanked() or length <= 1 or weight <= 1 then
            ------------------- event:10007 (already ranked trade) -------------------
            --param0 - x4[weight]x4[length]
            --param1 - length
            --param2 - weight
            --param3 - 1
            --param4 - 0 - valid, 1 - invalid
            --param5 - new fish score (if valid)
            --param6 - previous score (if valid and has score)
            --param7 - minutes
            player:startEvent(csid,lw,length,weight,1,1,score,prevscore, info.timeMinutes)
        else
            score = item:getScore()
            ------------------- event:10007 (valid trade) -------------------
            --param0 - 1 = preparing to accept, 2 = accepting, 3 = preparing to give results, 4 = giving results
            --param1 - fish id
            --param2 - 0 = size, 1 = weight, 2 = size and weight
            --param3 - 0 = greatest, 1 = smallest
            --param4 - 0 - valid, 1 - invalid
            --param5 - new fish score (if valid)
            --param6 - previous score (if valid and has score)
            --param7 - minutes
            player:startEvent(csid, info.period,item:getID(), info.currentStat, info.currentSize,0,score,prevscore, info.timeMinutes)
        end
    end
end

entity.onTrigger = function(player, npc)
    local debugMode = false
    local info = GetFishRankingInformation()

    if not debugMode then
        local hasRewards = 0
        local prevscore = player:getCurrentFishRankingScore()

        if info.period == 4 then
            local rank = player:getFishRankingRank()
            if rank > 0 and rank <= 20 and not player:hasClaimedFishingItems() then
                hasRewards = 1
            end
        end
        -- param0       period
        -- param1       fishid
        -- param2       stat
        -- param3       size
        -- param4       reward available (0/1)
        -- param5       current score
        -- param6       0
        -- param7       [period]:[minutes]
        printf("%d", info.period)
        player:startEvent(10006, info.period, info.currentFishId, info.currentStat, info.currentSize, hasRewards, prevscore, 0, 0)
    else
        --param0 - contesting           = 0,
        --         preparing to accept  = 1,
        --         accepting            = 2,
        --         preparing to release = 3,
        --         presenting results   = 4,
        --         not accepting        = 5,
        --         closed               = 6
        --param1:param3 - unknown
        --param4 - control mode (0 = automatic, 1 = semi-automatic, 2 = manual)
        --param5 - debug level (0 = none, 1 = displays, 2 = bypass board default errors)
        --param6 - time settings (0 = 2 weeks, 1 = step confirm - 30 seconds, 2 = qa speed - 30 minutes

        player:startEvent(10009,info.period,0,0,0,info.control,info.debug,info.timing,0)
    end
    --player:startEvent(10009,2,0,0,0,0,0,0)
end

entity.onEventUpdate = function(player, csid, option)
    local debugMode = false

    local info = GetFishRankingInformation()

    if csid == 10006 then
        -- withdraw entry
        if option == 152 and info.period == 2 then
            player:withdrawFishSubmission()
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,0,info.timeHours,info.timeMinutes)
        end
        -- confirm entry
        if option == 151 and info.period == 2 then
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,0,info.timeHours,info.timeMinutes)
        end
        -- default npc check
        if option == 150 then
            -- param0 - 1 = preparing to accept, 2 = accepting, 3 = preparing to give results, 4 = giving results
            -- param1 - fishid
            -- param2 - 0 = info.currentSize, 1 = weight, 2 = size and weight
            -- param3 - 0 = greatest, 1 = smallest
            -- param4 -
            -- param5 - days
            -- param6 - hours
            -- param7 - minutes
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,info.timeDays,info.timeHours,info.timeMinutes)
        end
        -- open menu
        if option == 149 then
            local rank = 0 --player:getFishRankingRank()
            if info.period == 4 then
                local notClaimed = 1
                if rank < 1 or rank > 20 or player:hasClaimedFishingItems() then
                    notClaimed = 0
                end
                player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,notClaimed,info.timeDays,info.timeHours,info.timeMinutes)
            else
                player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,info.timeDays,info.timeHours,info.timeMinutes)
            end
        end
        -- player done viewing ranking board, determine if they have received their title
        if option == 148 and info.period == 4 and not player:hasClaimedFishingTitle() then
            -- if player hasn't confirmed prize, param7 has first 4 bytes as 1, last 4 bytes are minutes
            local rank = player:getFishRankingRank()
            if rank <= 10 then
                SetRankingTitle(player, rank)
                player:claimFishingTitle()
                player:updateFishRankAwards(rank)
            end
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,3,3,4095,131115)
        end
        -- get award history
        if option == 147 then
            local awardhistory = player:getCharVar("[FishRanking]Awards")
            -- [0: ?], [1: fishid], [2: ?], [3: ?], [4: ?], [5: award histories[4,3,2,1]], [6: hours], [7: minutes]
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,awardhistory,info.timeHours,info.timeMinutes)
        end
    elseif csid == 10007 then
        -- accept ranking, pay 500 gil
        if option == 144 and info.period == 2 then
            -- param5 - 0 = success, 1 = fail
            -- if has enough gil then
            if player:getGil() >= 500 then
                local submitSuccess = player:submitFish()
                player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,submitSuccess,0,info.timeMinutes)
            else -- not enough gil
                -- param0 - 1 = preparing to accept, 2 = accepting, 3 = preparing to give results, 4 = giving results
                -- param1 - fishid
                -- param2 - 0 = size, 1 = weight, 2 = size and weight
                -- param3 - 0 = greatest, 1 = smallest
                -- param4 - 0
                -- param5 - 0xFFFFFFFE (-2 = not enough gil) (-1 = error processing)
                -- param6 - 0x0000012A (298)
                -- param7 - 0
                player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,0xFFFFFFFE,298,0)
            end
        end
        if option == 144 and info.period ~= 2 then -- tried submitting after period changed
            player:updateEvent(info.period,info.currentFishId,info.currentStat,info.currentSize,0,0xFFFFFFFF,298,0)
        end
        if option == 145 then

        end
    elseif csid == 10008 then

    elseif csid == 10009 and debugMode then
        -- options --
        -- 128 - debug level - 0 (default)
        if option == 128 then
            UpdateFishRankingConfiguration("debug", 0)
        end
        -- 129 - debug level - 1 (displays)
        if option == 129 then
            UpdateFishRankingConfiguration("debug", 1)
        end
        -- 130 - debug level - 2 (bypass board default errors)
        if option == 130 then
            UpdateFishRankingConfiguration("debug", 2)
        end
        -- 131 - change control mode - 0 (Automatic)
        if option == 131 then
            UpdateFishRankingConfiguration("control", 0)
        end
        -- 132 - change control mode - 1 (Semi-Automatic)
        if option == 132 then
            UpdateFishRankingConfiguration("control", 1)
        end
        -- 133 - change control mode - 2 (Manual)
        if option == 133 then
            UpdateFishRankingConfiguration("control", 2)
        end
        -- 134 - check rules - this time - param0 = 0, param1 = fishid, param2 = rule stat, param3 = rule size
        if option == 134 then
            player:messageSpecial(7639,0,info.currentFishId,info.currentStat,info.currentSize)
        end
        -- 135 - check rules - next time - param0 = 0, param1 = fishid, param2 = rule stat, param3 = rule size
        if option == 135 then
            player:messageSpecial(7640,0,info.nextFishId,info.nextStat,info.nextSize)
        end
        -- 136 - display time remaining until next step
        if option == 136 then
            player:messageSpecial(7689,info.timeDays,info.timeHours,info.timeMinutes,info.timeSeconds)
        end
        -- 137 - move to the next step
        if option == 137 then
            AdvanceFishRankingPeriod()
        end
        -- 138 - show menu (probably takes initial params)
        if option == 138 then
            player:updateEvent(info.period,0,0,0,info.control,info.debug,info.timing,0)
        end
        -- 139 - time setting - 0 (standard) A: 2 weeks, D: 15 minutes
        if option == 139 then
            UpdateFishRankingConfiguration("timing", 0)
        end
        -- 140 - time setting - 1 (step confirmation speed) A: 30 seconds, D: 30 seconds
        if option == 140 then
            UpdateFishRankingConfiguration("timing", 1)
        end
        -- 141 - time setting - 2 (qa debug speed)
        if option == 141 then
            UpdateFishRankingConfiguration("timing", 2)
        end
    end
end

entity.onEventFinish = function(player, csid, option)
    local debugMode = false
    local info = GetFishRankingInformation()

    if csid == 10006 and info.period == 4 then
        local rank = player:getFishRankingRank()
        -- receive awards if haven't yet
        if option == 149 and rank > 0 and rank <= 20 and not player:hasClaimedFishingItems() then
            if player:getFreeSlotsCount() > 0 then
                local gilReward = player:getFishRankingGilAmt()
                if rank <= 10 then
                    player:addGil(gilReward)
                    player:messageSpecial(ID.text.GIL_OBTAINED, gilReward)  -- Gil
                end
                player:addItem(15554)
                player:messageSpecial(ID.text.ITEM_OBTAINED, 15554) -- Pelican Ring
                player:claimFishingItems()
            else
                player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, 15554)
            end
        end
    elseif csid == 10007 and info.period == 2 then
        local tradeItems = player:getTrade()
        if option == 0 and tradeItems:hasItemQty(info.currentFishId, 1) then
            player:messageSpecial(ID.text.ITEM_OBTAINED, info.currentFishId)
        end
        -- finish ranking
        if option == 145 and player:getGil() >= 500 and tradeItems:hasItemQty(info.currentFishId, 1) then
            player:delGil(500)
            player:completeFishSubmission()
            player:messageSpecial(ID.text.ITEM_OBTAINED, info.currentFishId)
        end
    elseif csid == 10008 then
    -- ?

    elseif csid == 10009 and debugMode then
    -- ?

    end
end

return entity
