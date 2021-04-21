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

#include "animation.h"

#include "../entities/baseentity.h"

CAnimationPacket::CAnimationPacket(CBaseEntity* PEntity, uint16 animationID, uint16 animationType)
{
    this->type = 0x3A;
    this->size = 0x0A;

    ref<uint32>(0x04) = PEntity->id;
    ref<uint32>(0x08) = PEntity->id;   
    ref<uint16>(0x0C) = PEntity->targid;
    ref<uint16>(0x0E) = PEntity->targid;
    ref<uint16>(0x10) = animationID;
    ref<uint16>(0x12) = animationType;
}

CAnimationPacket::CAnimationPacket(CBaseEntity* PEntity, CBaseEntity* PTarget, uint16 animationID, uint16 animationType)
{
    this->type = 0x3A;
    this->size = 0x0A;

    ref<uint32>(0x04) = PEntity->id;
    ref<uint32>(0x08) = PTarget->id;
    ref<uint16>(0x0C) = PEntity->targid;
    ref<uint16>(0x0E) = PTarget->targid;
    ref<uint16>(0x10) = animationID;
    ref<uint16>(0x12) = animationType;
}
