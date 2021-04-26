/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

  This file is part of DarkStar-server source code.

===========================================================================
*/

#include "../../common/socket.h"
#include "../entities/charentity.h"
#include "fish_ranking_results.h"
#include <string.h>

CFishRankingResultsPacket::CFishRankingResultsPacket(CCharEntity* PChar, int8 submission_count, int8 language, int32 timestamp, int32 msg_chunk, int32 msg_offset, int32 msg_request_len)
{
    this->type = 0x4D;
    this->size = 0x20;

    uint8 start = (uint8)std::floor(msg_offset / 36);
    uint8 count = (uint8)std::floor(msg_request_len / 36);

    ref<uint8>(0x04) = msg_chunk;
    ref<uint8>(0x05) = 1;
    ref<uint8>(0x06) = 2; // 2 for fish ranking result
    ref<uint8>(0x07) = language;
    ref<uint32>(0x08) = (uint32)(timestamp == 0 ? time(0) : timestamp);
    submission_count = std::min(40, (int)submission_count);
    ref<uint32>(0x0C) = submission_count * 36; // Message Length (total submissions * 36) 

    ref<uint32>(0x10) = msg_offset;        // Message Offset..
    ref<uint32>(0x14) = msg_request_len;   // Message Length..

    ref<uint32>(0x18) = submission_count; // total submissions

    fish_ranking_listing* frl = nullptr;
    if (msg_chunk != 2)
    {
        frl = fishingutils::GetFishRankingListing(PChar);
        if (frl != nullptr)
        {
            memcpy(data + (0x1C), frl, 36);
            delete frl;
            frl = nullptr;
        }
        else
        {
            memset(data + (0x1C), 0, 36);
        }
    }

    if (msg_chunk <= 2)
    {
        this->size = 0x20 + (count * 18);
        std::list<fish_ranking_listing>* ranking_board = fishingutils::GetFishRankingListings(submission_count, start, count);

        uint16 counter = 0x1C + 36;
        if (ranking_board != nullptr)
        {
            for (auto it = ranking_board->begin(); it != ranking_board->end(); ++it)
            {
                fish_ranking_listing listing = *it;
                memcpy(data + (counter), &listing, 36);
                counter += 36;                
            }
            ranking_board->clear();
            delete ranking_board;
            ranking_board = nullptr;
        }
    }
    
}
