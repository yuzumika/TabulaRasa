xi = xi or {}
xi.mogTablet = xi.mogTablet or {}

-- 0 : A mog tablet has been discovered in [West Ronfaure/East Ronfaure/the La Theine Plateau/the Valkurm Dunes/Jugner Forest/the Batallia Downs/North Gustaberg/South Gustaberg/the Konschtat Highlands/the Pashhow Marshlands/the Rolanberry Fields/Beaucedine Glacier/Xarcabard/West Sarutabaruta/East Sarutabaruta/the Tahrongi Canyon/the Buburimu Peninsula/the Meriphataud Mountains/the Sauromugue Champaign/Qufim Island/Behemoth's Dominion/Cape Teriggan/the Eastern Altepa Desert/the Sanctuary of Zi'Tah/Ro'Maeve/the Yuhtunga Jungle/the Yhoator Jungle/the Western Altepa Desert/the Valley of Sorrows]!
-- 1 : The complete set of mog tablets has been restored to Ru'Lude Gardens! The ancient magic of King Kupofried permeates the air to instill adventurers in this area with its Super Kupowers!
-- 2 : The strength of the ancient moogle magic has weakened, and the tablets have been scattered to the winds once more. You can feel your Super Kupowers begin to fade away...
-- 3 : This area is currently affected by the Super Kupower: Thrifty Transit!
-- 4 : This area is currently affected by the Super Kupower: Martial Master!
-- 5 : This area is currently affected by the Super Kupower: Blood of the Vampyr!
-- 6 : This area is currently affected by the Super Kupower: Treasure Hound!
-- 7 : This area is currently affected by the Super Kupower: Artisan's Advantage!
-- 8 : This area is currently affected by the Super Kupower: Myriad Mystery Boxes!
-- 9 : This area is currently affected by the Super Kupower: Dilatory Digestion!
-- 10 : This area is currently affected by the Super Kupower: Boundary Buster!
-- 11 : This area is currently affected by the Super Kupower: Bountiful Bazaar!
-- 12 : This area is currently affected by the Super Kupower: Swift Shoes!
-- 13 : This area is currently affected by the Super Kupower: Crystal Caboodle!
-- 14 : The ancient magic of King Kupofried fills the air, its glorious Super Kupowers bringing happiness and joy to the realm! Visit the Explorer Moogle in Ru'Lude Gardens to find out more.
-- 15 : This area is currently affected by the Super Kupower: [/Thrifty Transit/Martial Master/Blood of the Vampyr/Treasure Hound/Artisan's Advantage/Myriad Mystery Boxes/Dilatory Digestion/Boundary Buster/Bountiful Bazaar/Swift Shoes/Crystal Caboodle]! This area is currently affected by the Super Kupower: [/Thrifty Transit/Martial Master/Blood of the Vampyr/Treasure Hound/Artisan's Advantage/Myriad Mystery Boxes/Dilatory Digestion/Boundary Buster/Bountiful Bazaar/Swift Shoes/Crystal Caboodle]! This area is currently affected by the Super Kupower: [/Thrifty Transit/Martial Master/Blood of the Vampyr/Treasure Hound/Artisan's Advantage/Myriad Mystery Boxes/Dilatory Digestion/Boundary Buster/Bountiful Bazaar/Swift Shoes/Crystal Caboodle]!

-- For use with message 0
xi.mogTablet.zones =
{
    WEST_RONFAURE          = 0,
    EAST_RONFAURE          = 1,
    LA_THEINE_PLATEAU      = 2,
    VALKURM_DUNES          = 3,
    JUGNER_FOREST          = 4,
    BATALLIA_DOWNS         = 5,
    NORTH_GUSTABERG        = 6,
    SOUTH_GUSTABERG        = 7,
    KONSCHTAT_HIGHLANDS    = 8,
    PASHHOW_MARSHLANDS     = 9,
    ROLANBERRY_FIELDS      = 10,
    BEAUCEDINE_GLACIER     = 11,
    XARCABARD              = 12,
    WEST_SARUTABARUTA      = 13,
    EAST_SARUTABARUTA      = 14,
    TAHRONGI_CANYON        = 15,
    BUBURIMU_PENINSULA     = 16,
    MERIPHATAUD_MOUNTAINS  = 17,
    SAUROMUGUE_CHAMPAIGN   = 18,
    QUFIM_ISLAND           = 19,
    BEHEMOTHS_DOMINION     = 20,
    CAPE_TERIGGAN          = 21,
    EASTERN_ALTEPA_DESERT  = 22,
    THE_SANCTUARY_OF_ZITAH = 23,
    ROMAEVE                = 24,
    YUHTUNGA_JUNGLE        = 25,
    YHOATOR_JUNGLE         = 26,
    WESTERN_ALTEPA_DESERT  = 27,
    VALLEY_OF_SORROWS      = 28,
}

-- For use with message 15
xi.mogTablet.powers =
{
    THRIFTY_TRANSIT      = 1,
    MARTIAL_MASTER       = 2,
    BLOOD_OF_THE_VAMPYR  = 3,
    TREASURE_HOUND       = 4,
    ARTISANS_ADVANTAGE   = 5,
    MYRIAD_MYSTERY_BOXES = 6,
    DILATORY_DIGESTION   = 7,
    BOUNDARY_BUSTER      = 8,
    BOUNTIFUL_BAZAAR     = 9,
    SWIFT_SHOES          = 10,
    CRYSTAL_CABOODLE     = 11,
}

xi.mogTablet.onZoneIn = function(zone, player)
    player:messageSpecial(15,
        xi.mogTablet.powers.THRIFTY_TRANSIT,
        xi.mogTablet.powers.MARTIAL_MASTER,
        xi.mogTablet.powers.BLOOD_OF_THE_VAMPYR)
end

-- Explorer Moogle in Ru'Lude Gardens
-- Intro cs 10108
-- Thanks to your efforts they have been recovered cs 10109
-- Tablets have been scattered cs 10110
-- You found a tablet cs 10111, 10112

xi.mogTablet.moogleOnTrigger = function(player, npc)
    local numberOfTabletsFound = 2
    player:startEvent(10108, numberOfTabletsFound, 4)
end

xi.mogTablet.moogleOnEventUpdate = function(player, csid, option)
    print("update", csid, option)
end

xi.mogTablet.moogleOnEventFinish = function(player, csid, option)
    print("finish", csid, option)
end