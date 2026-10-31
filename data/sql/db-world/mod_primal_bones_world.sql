-- mod-primal-bones: the Zandalar bonewright Ju'zaro, the ten-thousand-bone rite, and the beasts of
-- Un'Goro Crater that feed it.
--
--   item 1963        Primal Bone. Repurposes Blizzard's unused "Deprecated Bone Chips" row: the
--                    client already has a bone icon for that entry (INV_Misc_Bone_07), a new entry
--                    would show a question mark. Soulbound, stacks to 9,999, at most 9,999.
--   item 23357       Primal Egg (repurposed "NPC Equip 23357", egg icon). Hatches after three days,
--                    offline time included: the module's item script swaps it for
--   item 20798       Hatched Primal Egg (repurposed "NPC Equip 20798", egg icon), which opens:
--                    a Red, Black or Green Primal Raptor, Savage Raptor or Swift Albino Raptor
--                    you don't have yet, or 25 boss coins.
--   creature 9506000 Ju'zaro, Zandalar Bonewright, camped on the rim of the Lakkari Tar Pits.
--   quest 9506000    The Bonewright's Price: 100 bones, and Ju'zaro's shop opens. He sells the
--                    Bone-White Primal Raptor (9,999 bones) and pets (500 and 250), for Primal
--                    Bones only (the other primal raptors only hatch, the direhorns only drop;
--                    prices: ItemExtendedCost 90430, 90432 and 90433, which the client needs too:
--                    tools/build_patch.py).
--   creatures        Tarborn Tyrant, rare elite primal devilsaur, one entry per striped skin;
--   9506001, 9506005 no mount (the direhorns are the Warbringers', the raptors hatch); three
--                    spawn spots, one Tyrant at a time.
--   ..9506008
--   creatures        Zandalari Warbringer, rare elite, one entry per direhorn it rides and drops,
--   9506002-9506004, all eight colours of the direhorn mount: Slate, Amber, Jade or Cobalt
--   9506009-9506013  Primordial, Crimson or Golden Primal, Palehide or Zandalari Direhorn; five
--                    spawn spots, one Warbringer at a time.
--
-- Bones and eggs drop for a player who is on Ju'zaro's quest or has done it (loot conditions), and
-- for nobody else.
--
-- Needs the item and creature rows of wow-mod-retail-collection (the rewards, 400000+ and 410000+),
-- wow-mod-boss-coins' coin (item 90410, what an egg gives once all five raptors are known)
-- and the looks of wow-mod-retail-library (the direhorns the Warbringers ride and the Tyrant's
-- striped devilsaur, displays 247249/247271/247272/247273/276972).
--
-- This module's ids: creature, quest, npc_text, gossip menu, reference loot, pool and spawn guids
-- 9506000-9506099; ItemExtendedCost 90430-90439. Stock rows changed: the three repurposed items above, and new loot rows on 22
-- Un'Goro creatures (only rows for this module's items). Idempotent. Undo with
-- data/sql/uninstall/mod_primal_bones_uninstall_world.sql.

-- ---------------------------------------------------------------------------------------------
-- Items
-- ---------------------------------------------------------------------------------------------

-- Quest class (12) on the server so no trade-goods rule (stack size, reagent banks) picks it up.
-- Bonding 1, not 4: the core destroys quest-bound (4) objective items when any quest that needs
-- them is abandoned, which would take the whole pile with it.
UPDATE `item_template` SET `class` = 12, `subclass` = 0, `name` = 'Primal Bone', `Quality` = 1, `Flags` = 0,
  `BuyPrice` = 0, `SellPrice` = 0, `ItemLevel` = 60, `maxcount` = 9999, `stackable` = 9999, `bonding` = 1,
  `description` = 'Stained black by the tar, bleached white underneath. Ju''zaro of the Zandalar wants every one of them.'
WHERE `entry` = 1963;

-- Duration 259200 s = three days. flagsCustom 1: the duration also runs while the owner is offline.
UPDATE `item_template` SET `class` = 15, `subclass` = 0, `name` = 'Primal Egg', `Quality` = 3, `Flags` = 0,
  `ItemLevel` = 60, `maxcount` = 0, `stackable` = 1, `bonding` = 1, `duration` = 259200, `flagsCustom` = 1,
  `ScriptName` = 'item_primal_egg',
  `description` = 'Warm, and getting warmer. Something inside knocks back when you tap the shell.'
WHERE `entry` = 23357;

-- Flags 4: it opens like a container.
UPDATE `item_template` SET `class` = 15, `subclass` = 0, `name` = 'Hatched Primal Egg', `Quality` = 3, `Flags` = 4,
  `ItemLevel` = 60, `maxcount` = 0, `stackable` = 20, `bonding` = 1,
  `description` = 'The shell is split and something is chewing its way out.'
WHERE `entry` = 20798;

-- What hatches: one of five raptor mounts, a fifth each (the three primal raptors, the Savage
-- Raptor and the Swift Albino Raptor), and no other mount or pet. The module's loot script
-- (src/PrimalBones.cpp) only lets an egg hatch a raptor its owner doesn't know yet, sharing the
-- odds among the rest. An owner who knows all five gets 25 boss
-- coins instead (mod-boss-coins' Tarnished Undermine Real 90410; an equal-chance entry, so it
-- only drops when no raptor does; the raptors stay under 100% together, or the core logs that
-- it never can).
DELETE FROM `item_loot_template` WHERE `Entry` = 20798;
INSERT INTO `item_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(20798, 400538, 0, 19.9, 0, 1, 1, 1, 1, 'mod-primal-bones: Red Primal Raptor'),
(20798, 400539, 0, 19.9, 0, 1, 1, 1, 1, 'mod-primal-bones: Black Primal Raptor'),
(20798, 400540, 0, 19.9, 0, 1, 1, 1, 1, 'mod-primal-bones: Green Primal Raptor'),
(20798, 400418, 0, 19.9, 0, 1, 1, 1, 1, 'mod-primal-bones: Savage Raptor'),
(20798, 401180, 0, 19.9, 0, 1, 1, 1, 1, 'mod-primal-bones: Swift Albino Raptor'),
(20798, 90410, 0, 0, 0, 1, 1, 25, 25, 'mod-primal-bones: Tarnished Undermine Real, once all five raptors are known');

-- ---------------------------------------------------------------------------------------------
-- Ju'zaro
-- ---------------------------------------------------------------------------------------------

-- The Zandalarian Emissary's model (15210) and weapon. Faction 35: friendly to everyone.
-- npcflag 131: gossip, quests and vendor. unit_flags 768: nothing attacks him.
DELETE FROM `creature_template` WHERE `entry` = 9506000;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `HealthModifier`, `flags_extra`) VALUES
(9506000, 'Ju''zaro', 'Zandalar Bonewright', 9506000, 60, 60, 35, 131, 1, 1.14286, 2000, 2000, 1, 768, 2048, 7, 3, 2);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9506000;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9506000, 0, 15210, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` = 9506000;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9506000, 1, 13336, 0, 0, 0);

-- What he says depends on whether you have done his quest and on the bones in your bags. Exactly
-- one of the texts below fits any player (the conditions further down), so the order the core
-- reads them in doesn't matter.
DELETE FROM `npc_text` WHERE `ID` BETWEEN 9506000 AND 9506006;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9506000, 'Da crater would eat you alive, little one. Da devilsaurs don''t care how brave you be.$B$BCome back when you be strong enough to stand in da tar and walk out again.', 'Da crater would eat you alive, little one. Da devilsaurs don''t care how brave you be.$B$BCome back when you be strong enough to stand in da tar and walk out again.', 1),
(9506001, 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BJu''zaro trades with hunters, not tourists. Show Ju''zaro you can hunt, and you see what da tar gave up.', 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BJu''zaro trades with hunters, not tourists. Show Ju''zaro you can hunt, and you see what da tar gave up.', 1),
(9506006, 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BDa beasts of dis crater carry da oldest blood on Azeroth. Bring Ju''zaro dere bones, and pick what you like.', 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BDa beasts of dis crater carry da oldest blood on Azeroth. Bring Ju''zaro dere bones, and pick what you like.', 1),
(9506002, 'A quarter of da rite already. Ju''zaro can hear da tar listenin'' now.', 'A quarter of da rite already. Ju''zaro can hear da tar listenin'' now.', 1),
(9506003, 'Half. Somethin'' under da pitch be stirrin'', $N. Somethin'' pale.', 'Half. Somethin'' under da pitch be stirrin'', $N. Somethin'' pale.', 1),
(9506004, 'So close. Da old bones be whisperin'' your name in da night. Ju''zaro hears it too.', 'So close. Da old bones be whisperin'' your name in da night. Ju''zaro hears it too.', 1),
(9506005, 'Nine thousand, nine hundred and ninety-nine! Dat be da whole rite, $N. Da white one be waitin'' in Ju''zaro''s wares.', 'Nine thousand, nine hundred and ninety-nine! Dat be da whole rite, $N. Da white one be waitin'' in Ju''zaro''s wares.', 1);

DELETE FROM `gossip_menu` WHERE `MenuID` = 9506000;
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9506000, 9506000), (9506000, 9506001), (9506000, 9506002), (9506000, 9506003), (9506000, 9506004), (9506000, 9506005), (9506000, 9506006);

-- Source type 14 (gossip menu text). Type 27: level, compared 2 (lower) or 3 (at least). Type 8:
-- quest 9506000 done. Type 2: that many Primal Bones in the bags. NegativeCondition 1 turns a row
-- around.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 14 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(14, 9506000, 9506000, 0, 0, 27, 0, 60, 2, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, below level 60'),
(14, 9506000, 9506001, 0, 0, 27, 0, 60, 3, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, level 60'),
(14, 9506000, 9506001, 0, 0, 8, 0, 9506000, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop not open yet'),
(14, 9506000, 9506006, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop open'),
(14, 9506000, 9506006, 0, 0, 2, 0, 1963, 2500, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 2500 bones'),
(14, 9506000, 9506002, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop open'),
(14, 9506000, 9506002, 0, 0, 2, 0, 1963, 2500, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 2500 bones'),
(14, 9506000, 9506002, 0, 0, 2, 0, 1963, 5000, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 5000 bones'),
(14, 9506000, 9506003, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop open'),
(14, 9506000, 9506003, 0, 0, 2, 0, 1963, 5000, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 5000 bones'),
(14, 9506000, 9506003, 0, 0, 2, 0, 1963, 7500, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 7500 bones'),
(14, 9506000, 9506004, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop open'),
(14, 9506000, 9506004, 0, 0, 2, 0, 1963, 7500, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 7500 bones'),
(14, 9506000, 9506004, 0, 0, 2, 0, 1963, 9999, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 9999 bones'),
(14, 9506000, 9506005, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, shop open'),
(14, 9506000, 9506005, 0, 0, 2, 0, 1963, 9999, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 9999 bones');

-- His wares: a gossip option that opens the vendor list, shown once his quest is done (source
-- type 15, type 8). Icon 0 (chat): a 3.3.5 client offered a single option with any other icon
-- opens it straight away and skips the greeting.
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 9506000;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcFlag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`, `VerifiedBuild`) VALUES
(9506000, 0, 0, 'Show me what the tar gave up.', 0, 3, 128, 0, 0, 0, 0, '', 0, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(15, 9506000, 0, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro''s wares, after his quest');

-- ---------------------------------------------------------------------------------------------
-- The quest
-- ---------------------------------------------------------------------------------------------

-- Level 60, filed under Un'Goro Crater (490), no experience or money: it opens Ju'zaro's shop.
-- Flags 64: can be done in a raid group, so bones and eggs still drop for players in one. Ids
-- 9506001-9506015 were the trade quests of earlier versions; the DELETEs still clear them.
DELETE FROM `quest_template` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `Flags`, `RequiredItemId1`, `RequiredItemCount1`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `VerifiedBuild`) VALUES
(9506000, 2, 60, 60, 490, 0, 64, 1963, 100,
 'The Bonewright''s Price',
 'Bring 100 Primal Bones to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.',
 'You smell dat, $C? Tar, and old blood. Dis crater be da oldest garden on Azeroth. Da titans planted it, and da beasts here still carry da first bloodlines in dere bones.$B$BDa Zandalar been raisin'' raptors since before your kingdoms had names. Ju''zaro trades in what da tar gives up: primal raptors, direhorns, little ones from Zandalar. Ju''zaro takes bones for dem. Nothin'' else.$B$BBut Ju''zaro trades with hunters, not tourists. Bring a hundred bones from da crater''s beasts, and Ju''zaro shows you his wares.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0);

DELETE FROM `quest_request_items` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`, `VerifiedBuild`) VALUES
(9506000, 1, 1, 'Every beast in dis crater be carryin'' bones, mon. Only a fool leaves dem in da dirt.', 0);

DELETE FROM `quest_offer_reward` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `Emote2`, `Emote3`, `Emote4`, `EmoteDelay1`, `EmoteDelay2`, `EmoteDelay3`, `EmoteDelay4`, `RewardText`, `VerifiedBuild`) VALUES
(9506000, 4, 0, 0, 0, 0, 0, 0, 0, 'A hundred, and clean ones. You be a hunter after all.$B$BKeep bringin'' dem. Da white raptor costs nine thousand, nine hundred and ninety-nine, and da last bone grows inside da egg. When it hatches it be white as all da rest.$B$BSee what Ju''zaro has, $N.', 0);

DELETE FROM `creature_queststarter` WHERE `quest` BETWEEN 9506000 AND 9506015;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9506000, 9506000);
DELETE FROM `creature_questender` WHERE `quest` BETWEEN 9506000 AND 9506015;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9506000, 9506000);

-- ---------------------------------------------------------------------------------------------
-- The shop
-- ---------------------------------------------------------------------------------------------

-- The prices, in Primal Bones. The client needs the same ItemExtendedCost rows, or the vendor
-- window shows no price and won't buy: tools/build_patch.py adds them to your realm's spell and
-- item patch. 90430-90439 are this module's; 90431 was the Palehide Direhorn's 3,333 bones, which
-- now drops from a Warbringer instead.
DELETE FROM `itemextendedcost_dbc` WHERE `ID` BETWEEN 90430 AND 90439;
INSERT INTO `itemextendedcost_dbc` (`ID`, `HonorPoints`, `ArenaPoints`, `ArenaBracket`, `ItemID_1`, `ItemID_2`, `ItemID_3`, `ItemID_4`, `ItemID_5`, `ItemCount_1`, `ItemCount_2`, `ItemCount_3`, `ItemCount_4`, `ItemCount_5`, `RequiredArenaRating`, `ItemPurchaseGroup`) VALUES
(90430, 0, 0, 0, 1963, 0, 0, 0, 0, 9999, 0, 0, 0, 0, 0, 0),
(90432, 0, 0, 0, 1963, 0, 0, 0, 0, 500, 0, 0, 0, 0, 0, 0),
(90433, 0, 0, 0, 1963, 0, 0, 0, 0, 250, 0, 0, 0, 0, 0, 0);

-- Every ware teaches a mount or pet whose spell has the item's own id. Each shows only after his
-- quest (type 8) and while you don't know its spell yet (type 25, negated), so nobody buys one
-- twice. Source type 23: SourceGroup the vendor, SourceEntry the item.
DELETE FROM `npc_vendor` WHERE `entry` = 9506000;
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`, `VerifiedBuild`) VALUES
(9506000, 0, 400537, 0, 0, 90430, 0),
(9506000, 1, 411180, 0, 0, 90432, 0),
(9506000, 2, 411211, 0, 0, 90432, 0),
(9506000, 3, 411212, 0, 0, 90432, 0),
(9506000, 4, 411213, 0, 0, 90432, 0),
(9506000, 5, 412413, 0, 0, 90432, 0),
(9506000, 6, 412537, 0, 0, 90432, 0),
(9506000, 7, 411200, 0, 0, 90432, 0),
(9506000, 8, 412412, 0, 0, 90432, 0),
(9506000, 9, 411184, 0, 0, 90432, 0),
(9506000, 10, 412197, 0, 0, 90433, 0),
(9506000, 11, 410504, 0, 0, 90433, 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 23 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(23, 9506000, 400537, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Bone-White Primal Raptor, after Ju''zaro''s quest'),
(23, 9506000, 400537, 0, 0, 25, 0, 400537, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Bone-White Primal Raptor, not known yet'),
(23, 9506000, 411180, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Kneebiter, after Ju''zaro''s quest'),
(23, 9506000, 411180, 0, 0, 25, 0, 411180, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Zandalari Kneebiter, not known yet'),
(23, 9506000, 411211, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Anklerender, after Ju''zaro''s quest'),
(23, 9506000, 411211, 0, 0, 25, 0, 411211, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Zandalari Anklerender, not known yet'),
(23, 9506000, 411212, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Footslasher, after Ju''zaro''s quest'),
(23, 9506000, 411212, 0, 0, 25, 0, 411212, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Zandalari Footslasher, not known yet'),
(23, 9506000, 411213, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Toenibbler, after Ju''zaro''s quest'),
(23, 9506000, 411213, 0, 0, 25, 0, 411213, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Zandalari Toenibbler, not known yet'),
(23, 9506000, 412413, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Shinchomper, after Ju''zaro''s quest'),
(23, 9506000, 412413, 0, 0, 25, 0, 412413, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Zandalari Shinchomper, not known yet'),
(23, 9506000, 412537, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Baby Zandalari Raptor, after Ju''zaro''s quest'),
(23, 9506000, 412537, 0, 0, 25, 0, 412537, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Baby Zandalari Raptor, not known yet'),
(23, 9506000, 411200, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Pygmy Direhorn, after Ju''zaro''s quest'),
(23, 9506000, 411200, 0, 0, 25, 0, 411200, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Pygmy Direhorn, not known yet'),
(23, 9506000, 412412, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tiny Direhorn, after Ju''zaro''s quest'),
(23, 9506000, 412412, 0, 0, 25, 0, 412412, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Tiny Direhorn, not known yet'),
(23, 9506000, 411184, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Stunted Direhorn, after Ju''zaro''s quest'),
(23, 9506000, 411184, 0, 0, 25, 0, 411184, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Stunted Direhorn, not known yet'),
(23, 9506000, 412197, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Direhorn Hatchling, after Ju''zaro''s quest'),
(23, 9506000, 412197, 0, 0, 25, 0, 412197, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Direhorn Hatchling, not known yet'),
(23, 9506000, 410504, 0, 0, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Diemetradon Hatchling, after Ju''zaro''s quest'),
(23, 9506000, 410504, 0, 0, 25, 0, 410504, 0, 0, 1, 0, 0, '', 'mod-primal-bones: Diemetradon Hatchling, not known yet');

-- ---------------------------------------------------------------------------------------------
-- The rares
-- ---------------------------------------------------------------------------------------------

-- Tarborn Tyrants: primal devilsaurs that crawled out of the tar, built like King Mosh (rank 2,
-- rare elite; same health, damage and abilities). One entry for each of retail's five striped
-- primal devilsaur skins. None drops a mount: the direhorns are the Warbringers' and the raptors
-- hatch from Primal Eggs:
--   9506001  dark  (display 247249)
--   9506005  blue  (display 247271)
--   9506006  green (display 247272)
--   9506007  pale  (display 247273)
--   9506008  brown (display 276972)
-- Skinning gives what King Mosh's corpse gives.
DELETE FROM `creature_template` WHERE `entry` IN (9506001, 9506005, 9506006, 9506007, 9506008);
INSERT INTO `creature_template` (`entry`, `name`, `minlevel`, `maxlevel`, `faction`, `speed_walk`, `speed_run`, `rank`, `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `lootid`, `skinloot`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `RegenHealth`) VALUES
(9506001, 'Tarborn Tyrant', 61, 61, 14, 1.6, 1.71429, 2, 8.5, 1500, 2000, 1, 64, 2048, 1, 9506001, 6584, 3975, 5196, 'SmartAI', 20, 1),
(9506005, 'Tarborn Tyrant', 61, 61, 14, 1.6, 1.71429, 2, 8.5, 1500, 2000, 1, 64, 2048, 1, 9506005, 6584, 3975, 5196, 'SmartAI', 20, 1),
(9506006, 'Tarborn Tyrant', 61, 61, 14, 1.6, 1.71429, 2, 8.5, 1500, 2000, 1, 64, 2048, 1, 9506006, 6584, 3975, 5196, 'SmartAI', 20, 1),
(9506007, 'Tarborn Tyrant', 61, 61, 14, 1.6, 1.71429, 2, 8.5, 1500, 2000, 1, 64, 2048, 1, 9506007, 6584, 3975, 5196, 'SmartAI', 20, 1),
(9506008, 'Tarborn Tyrant', 61, 61, 14, 1.6, 1.71429, 2, 8.5, 1500, 2000, 1, 64, 2048, 1, 9506008, 6584, 3975, 5196, 'SmartAI', 20, 1);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (9506001, 9506005, 9506006, 9506007, 9506008);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9506001, 0, 247249, 1, 1, 0),
(9506005, 0, 247271, 1, 1, 0),
(9506006, 0, 247272, 1, 1, 0),
(9506007, 0, 247273, 1, 1, 0),
(9506008, 0, 276972, 1, 1, 0);

-- Zandalari Warbringers: the Zandalar Enforcer's model and gear, mounted on a Primordial
-- Direhorn from the retail library (creature_template_addon.mount). One entry per colour, so
-- each drops its own direhorn: 9506002 Slate (247715), 9506003 Amber (247718), 9506004 Jade
-- (247717) Primordial Direhorns, 9506009 the Crimson Primal Direhorn (248101), 9506010 the
-- Palehide Direhorn (287779), 9506011 the Cobalt Primordial Direhorn (247716), 9506012 the
-- Zandalari Direhorn (283525), 9506013 the Golden Primal Direhorn (248100). They're the only
-- source of these eight direhorns.
-- visibilityDistanceType 3: seen from further away, like other large rares.
DELETE FROM `creature_template` WHERE `entry` IN (9506002, 9506003, 9506004, 9506009, 9506010, 9506011, 9506012, 9506013);
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `speed_walk`, `speed_run`, `rank`, `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `RegenHealth`) VALUES
(9506002, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506002, 2000, 4000, 'SmartAI', 10, 1),
(9506003, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506003, 2000, 4000, 'SmartAI', 10, 1),
(9506004, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506004, 2000, 4000, 'SmartAI', 10, 1),
(9506009, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506009, 2000, 4000, 'SmartAI', 10, 1),
(9506010, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506010, 2000, 4000, 'SmartAI', 10, 1),
(9506011, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506011, 2000, 4000, 'SmartAI', 10, 1),
(9506012, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506012, 2000, 4000, 'SmartAI', 10, 1),
(9506013, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506013, 2000, 4000, 'SmartAI', 10, 1);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (9506002, 9506003, 9506004, 9506009, 9506010, 9506011, 9506012, 9506013);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9506002, 0, 15004, 1, 1, 0),
(9506003, 0, 15004, 1, 1, 0),
(9506004, 0, 15004, 1, 1, 0),
(9506009, 0, 15004, 1, 1, 0),
(9506010, 0, 15004, 1, 1, 0),
(9506011, 0, 15004, 1, 1, 0),
(9506012, 0, 15004, 1, 1, 0),
(9506013, 0, 15004, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` IN (9506002, 9506003, 9506004, 9506009, 9506010, 9506011, 9506012, 9506013);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9506002, 1, 18002, 0, 18019, 0),
(9506003, 1, 18002, 0, 18019, 0),
(9506004, 1, 18002, 0, 18019, 0),
(9506009, 1, 18002, 0, 18019, 0),
(9506010, 1, 18002, 0, 18019, 0),
(9506011, 1, 18002, 0, 18019, 0),
(9506012, 1, 18002, 0, 18019, 0),
(9506013, 1, 18002, 0, 18019, 0);

DELETE FROM `creature_template_addon` WHERE `entry` IN (9506002, 9506003, 9506004, 9506009, 9506010, 9506011, 9506012, 9506013);
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`) VALUES
(9506002, 0, 247715, 0, 1, 0, 3, NULL),
(9506003, 0, 247718, 0, 1, 0, 3, NULL),
(9506004, 0, 247717, 0, 1, 0, 3, NULL),
(9506009, 0, 248101, 0, 1, 0, 3, NULL),
(9506010, 0, 287779, 0, 1, 0, 3, NULL),
(9506011, 0, 247716, 0, 1, 0, 3, NULL),
(9506012, 0, 283525, 0, 1, 0, 3, NULL),
(9506013, 0, 248100, 0, 1, 0, 3, NULL);

-- Both announce themselves to the whole crater when they appear (TextRange 2: zone), so players
-- know one is up somewhere. Type 16: monster emote.
DELETE FROM `creature_text` WHERE `CreatureID` BETWEEN 9506001 AND 9506013;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(9506001, 0, 0, 'The Lakkari tar heaves, and something enormous claws its way out of the pit!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Tarborn Tyrant spawn'),
(9506001, 1, 0, '%s roars, and the whole crater goes quiet.', 16, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Tarborn Tyrant aggro'),
(9506005, 0, 0, 'The Lakkari tar heaves, and something enormous claws its way out of the pit!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Tarborn Tyrant spawn'),
(9506005, 1, 0, '%s roars, and the whole crater goes quiet.', 16, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Tarborn Tyrant aggro'),
(9506006, 0, 0, 'The Lakkari tar heaves, and something enormous claws its way out of the pit!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Tarborn Tyrant spawn'),
(9506006, 1, 0, '%s roars, and the whole crater goes quiet.', 16, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Tarborn Tyrant aggro'),
(9506007, 0, 0, 'The Lakkari tar heaves, and something enormous claws its way out of the pit!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Tarborn Tyrant spawn'),
(9506007, 1, 0, '%s roars, and the whole crater goes quiet.', 16, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Tarborn Tyrant aggro'),
(9506008, 0, 0, 'The Lakkari tar heaves, and something enormous claws its way out of the pit!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Tarborn Tyrant spawn'),
(9506008, 1, 0, '%s roars, and the whole crater goes quiet.', 16, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Tarborn Tyrant aggro'),
(9506002, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506002, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506003, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506003, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506004, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506004, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506009, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506009, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506010, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506010, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506011, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506011, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506012, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506012, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro'),
(9506013, 0, 0, 'War drums echo across the crater. A Zandalari Warbringer rides through Un''Goro!', 16, 0, 100, 0, 0, 0, 0, 2, 'mod-primal-bones: Warbringer spawn'),
(9506013, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro');

-- Tyrant: King Mosh's three attacks, plus the two lines above. Warbringers: Cleave, Mortal
-- Strike and a direhorn Thunderclap.
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` BETWEEN 9506001 AND 9506013;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9506001, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Respawn - Say Line 0'),
(9506001, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Aggro - Say Line 1'),
(9506001, 0, 2, 0, 0, 0, 100, 0, 10000, 10000, 12000, 20000, 0, 0, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Terrifying Roar'),
(9506001, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 14000, 19000, 0, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Trample'),
(9506001, 0, 4, 0, 9, 0, 100, 0, 0, 5, 4000, 13000, 0, 0, 11, 14331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - Within 0-5 Range - Cast Vicious Rend'),
(9506005, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Respawn - Say Line 0'),
(9506005, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Aggro - Say Line 1'),
(9506005, 0, 2, 0, 0, 0, 100, 0, 10000, 10000, 12000, 20000, 0, 0, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Terrifying Roar'),
(9506005, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 14000, 19000, 0, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Trample'),
(9506005, 0, 4, 0, 9, 0, 100, 0, 0, 5, 4000, 13000, 0, 0, 11, 14331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - Within 0-5 Range - Cast Vicious Rend'),
(9506006, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Respawn - Say Line 0'),
(9506006, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Aggro - Say Line 1'),
(9506006, 0, 2, 0, 0, 0, 100, 0, 10000, 10000, 12000, 20000, 0, 0, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Terrifying Roar'),
(9506006, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 14000, 19000, 0, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Trample'),
(9506006, 0, 4, 0, 9, 0, 100, 0, 0, 5, 4000, 13000, 0, 0, 11, 14331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - Within 0-5 Range - Cast Vicious Rend'),
(9506007, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Respawn - Say Line 0'),
(9506007, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Aggro - Say Line 1'),
(9506007, 0, 2, 0, 0, 0, 100, 0, 10000, 10000, 12000, 20000, 0, 0, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Terrifying Roar'),
(9506007, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 14000, 19000, 0, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Trample'),
(9506007, 0, 4, 0, 9, 0, 100, 0, 0, 5, 4000, 13000, 0, 0, 11, 14331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - Within 0-5 Range - Cast Vicious Rend'),
(9506008, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Respawn - Say Line 0'),
(9506008, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - On Aggro - Say Line 1'),
(9506008, 0, 2, 0, 0, 0, 100, 0, 10000, 10000, 12000, 20000, 0, 0, 11, 14100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Terrifying Roar'),
(9506008, 0, 3, 0, 0, 0, 100, 0, 8000, 8000, 14000, 19000, 0, 0, 11, 15550, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - In Combat - Cast Trample'),
(9506008, 0, 4, 0, 9, 0, 100, 0, 0, 5, 4000, 13000, 0, 0, 11, 14331, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Tarborn Tyrant - Within 0-5 Range - Cast Vicious Rend'),
(9506002, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506002, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506002, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506002, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506002, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506003, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506003, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506003, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506003, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506003, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506004, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506004, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506004, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506004, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506004, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506009, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506009, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506009, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506009, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506009, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506010, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506010, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506010, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506010, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506010, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506011, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506011, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506011, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506011, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506011, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506012, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506012, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506012, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506012, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506012, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap'),
(9506013, 0, 0, 0, 11, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Respawn - Say Line 0'),
(9506013, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - On Aggro - Say Line 1'),
(9506013, 0, 2, 0, 0, 0, 100, 0, 5000, 7000, 6000, 9000, 0, 0, 11, 15284, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Cleave'),
(9506013, 0, 3, 0, 0, 0, 100, 0, 9000, 12000, 10000, 14000, 0, 0, 11, 13737, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Mortal Strike'),
(9506013, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap');

-- ---------------------------------------------------------------------------------------------
-- Loot
-- ---------------------------------------------------------------------------------------------

-- Bones and eggs drop for players on Ju'zaro's quest (type 9: taken, not yet complete) or who
-- have done it (type 8), and for nobody else: one ElseGroup each, on every bone row (source type 1,
-- creature loot) and on the egg reference (source type 10). About 4-5 bones a kill from the
-- crater's beasts, 15-25 from its elites and far more from the rares: roughly twelve hours of
-- hunting for 9,999 alone. Every egg is a primal raptor, which the shop used to sell for 3,333
-- bones, so an egg takes about the kills 3,333 bones do: egg chance = average bones / 3,333
-- (beasts 0.135%, tar elementals 0.09%, elites 0.6%, Ravasaur Matriarch 1.95%, Gruff 3.75%,
-- King Mosh 6%, Warbringer 2.4%, Tyrant 6.75%). Rows with these conditions are each player's
-- own, like quest loot.
DELETE FROM `creature_loot_template` WHERE `Item` IN (1963, 9506000) AND `Entry` IN (6505, 6506, 6507, 6508, 9162, 9163, 9164, 9165, 9166, 9167, 6517, 6518, 6519, 6527, 6501, 6502, 6503, 6504, 6498, 6581, 6583, 6584);
DELETE FROM `creature_loot_template` WHERE `Entry` BETWEEN 9506001 AND 9506013;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(6505, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur - Primal Bone'),
(6505, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur - Primal Egg'),
(6506, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur Runner - Primal Bone'),
(6506, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Runner - Primal Egg'),
(6507, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur Hunter - Primal Bone'),
(6507, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Hunter - Primal Egg'),
(6508, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Venomhide Ravasaur - Primal Bone'),
(6508, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Venomhide Ravasaur - Primal Egg'),
(9162, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Young Diemetradon - Primal Bone'),
(9162, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Young Diemetradon - Primal Egg'),
(9163, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Diemetradon - Primal Bone'),
(9163, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Diemetradon - Primal Egg'),
(9164, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Elder Diemetradon - Primal Bone'),
(9164, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Elder Diemetradon - Primal Egg'),
(9165, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Fledgling Pterrordax - Primal Bone'),
(9165, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Fledgling Pterrordax - Primal Egg'),
(9166, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Pterrordax - Primal Bone'),
(9166, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Pterrordax - Primal Egg'),
(9167, 1963, 0, 100, 0, 1, 0, 3, 6, 'mod-primal-bones: Frenzied Pterrordax - Primal Bone'),
(9167, 9506000, 9506000, 0.135, 0, 1, 0, 1, 1, 'mod-primal-bones: Frenzied Pterrordax - Primal Egg'),
(6517, 1963, 0, 100, 0, 1, 0, 2, 4, 'mod-primal-bones: Tar Beast - Primal Bone'),
(6517, 9506000, 9506000, 0.09, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Beast - Primal Egg'),
(6518, 1963, 0, 100, 0, 1, 0, 2, 4, 'mod-primal-bones: Tar Lurker - Primal Bone'),
(6518, 9506000, 9506000, 0.09, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Lurker - Primal Egg'),
(6519, 1963, 0, 100, 0, 1, 0, 2, 4, 'mod-primal-bones: Tar Lord - Primal Bone'),
(6519, 9506000, 9506000, 0.09, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Lord - Primal Egg'),
(6527, 1963, 0, 100, 0, 1, 0, 2, 4, 'mod-primal-bones: Tar Creeper - Primal Bone'),
(6527, 9506000, 9506000, 0.09, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Creeper - Primal Egg'),
(6501, 1963, 0, 100, 0, 1, 0, 15, 25, 'mod-primal-bones: Stegodon - Primal Bone'),
(6501, 9506000, 9506000, 0.6, 0, 1, 0, 1, 1, 'mod-primal-bones: Stegodon - Primal Egg'),
(6502, 1963, 0, 100, 0, 1, 0, 15, 25, 'mod-primal-bones: Plated Stegodon - Primal Bone'),
(6502, 9506000, 9506000, 0.6, 0, 1, 0, 1, 1, 'mod-primal-bones: Plated Stegodon - Primal Egg'),
(6503, 1963, 0, 100, 0, 1, 0, 15, 25, 'mod-primal-bones: Spiked Stegodon - Primal Bone'),
(6503, 9506000, 9506000, 0.6, 0, 1, 0, 1, 1, 'mod-primal-bones: Spiked Stegodon - Primal Egg'),
(6504, 1963, 0, 100, 0, 1, 0, 15, 25, 'mod-primal-bones: Thunderstomp Stegodon - Primal Bone'),
(6504, 9506000, 9506000, 0.6, 0, 1, 0, 1, 1, 'mod-primal-bones: Thunderstomp Stegodon - Primal Egg'),
(6498, 1963, 0, 100, 0, 1, 0, 15, 25, 'mod-primal-bones: Devilsaur - Primal Bone'),
(6498, 9506000, 9506000, 0.6, 0, 1, 0, 1, 1, 'mod-primal-bones: Devilsaur - Primal Egg'),
(6581, 1963, 0, 100, 0, 1, 0, 50, 80, 'mod-primal-bones: Ravasaur Matriarch - Primal Bone'),
(6581, 9506000, 9506000, 1.95, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Matriarch - Primal Egg'),
(6583, 1963, 0, 100, 0, 1, 0, 100, 150, 'mod-primal-bones: Gruff - Primal Bone'),
(6583, 9506000, 9506000, 3.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Gruff - Primal Egg'),
(6584, 1963, 0, 100, 0, 1, 0, 150, 250, 'mod-primal-bones: King Mosh - Primal Bone'),
(6584, 9506000, 9506000, 6, 0, 1, 0, 1, 1, 'mod-primal-bones: King Mosh - Primal Egg'),
(9506001, 1963, 0, 100, 0, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (dark) - Primal Bone'),
(9506001, 9506000, 9506000, 6.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (dark) - Primal Egg'),
(9506005, 1963, 0, 100, 0, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (blue) - Primal Bone'),
(9506005, 9506000, 9506000, 6.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (blue) - Primal Egg'),
(9506006, 1963, 0, 100, 0, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (green) - Primal Bone'),
(9506006, 9506000, 9506000, 6.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (green) - Primal Egg'),
(9506007, 1963, 0, 100, 0, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (pale) - Primal Bone'),
(9506007, 9506000, 9506000, 6.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (pale) - Primal Egg'),
(9506008, 1963, 0, 100, 0, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (brown) - Primal Bone'),
(9506008, 9506000, 9506000, 6.75, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (brown) - Primal Egg'),
(9506002, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Slate) - Primal Bone'),
(9506002, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Slate) - Primal Egg'),
(9506003, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Amber) - Primal Bone'),
(9506003, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Amber) - Primal Egg'),
(9506004, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Jade) - Primal Bone'),
(9506004, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Jade) - Primal Egg'),
(9506009, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Crimson) - Primal Bone'),
(9506009, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Crimson) - Primal Egg'),
(9506010, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Palehide) - Primal Bone'),
(9506010, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Palehide) - Primal Egg'),
(9506011, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Cobalt) - Primal Bone'),
(9506011, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Cobalt) - Primal Egg'),
(9506012, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Zandalari) - Primal Bone'),
(9506012, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Zandalari) - Primal Egg'),
(9506013, 1963, 0, 100, 0, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Golden) - Primal Bone'),
(9506013, 9506000, 9506000, 2.4, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Golden) - Primal Egg'),
(9506002, 400535, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Slate Primordial Direhorn'),
(9506003, 400534, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Amber Primordial Direhorn'),
(9506004, 400536, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Jade Primordial Direhorn'),
(9506009, 400546, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Crimson Primal Direhorn'),
(9506010, 401179, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Palehide Direhorn'),
(9506011, 400533, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Cobalt Primordial Direhorn'),
(9506012, 401038, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Zandalari Direhorn'),
(9506013, 400545, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Golden Primal Direhorn');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 1 AND `SourceEntry` = 1963 AND `SourceGroup` IN (6505, 6506, 6507, 6508, 9162, 9163, 9164, 9165, 9166, 9167, 6517, 6518, 6519, 6527, 6501, 6502, 6503, 6504, 6498, 6581, 6583, 6584, 9506001, 9506005, 9506006, 9506007, 9506008, 9506002, 9506003, 9506004, 9506009, 9506010, 9506011, 9506012, 9506013);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(1, 6505, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur - bones while on Ju''zaro''s quest'),
(1, 6505, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur - bones once his shop is open'),
(1, 6506, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Runner - bones while on Ju''zaro''s quest'),
(1, 6506, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Runner - bones once his shop is open'),
(1, 6507, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Hunter - bones while on Ju''zaro''s quest'),
(1, 6507, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Hunter - bones once his shop is open'),
(1, 6508, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Venomhide Ravasaur - bones while on Ju''zaro''s quest'),
(1, 6508, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Venomhide Ravasaur - bones once his shop is open'),
(1, 9162, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Young Diemetradon - bones while on Ju''zaro''s quest'),
(1, 9162, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Young Diemetradon - bones once his shop is open'),
(1, 9163, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Diemetradon - bones while on Ju''zaro''s quest'),
(1, 9163, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Diemetradon - bones once his shop is open'),
(1, 9164, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Elder Diemetradon - bones while on Ju''zaro''s quest'),
(1, 9164, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Elder Diemetradon - bones once his shop is open'),
(1, 9165, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Fledgling Pterrordax - bones while on Ju''zaro''s quest'),
(1, 9165, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Fledgling Pterrordax - bones once his shop is open'),
(1, 9166, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Pterrordax - bones while on Ju''zaro''s quest'),
(1, 9166, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Pterrordax - bones once his shop is open'),
(1, 9167, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Frenzied Pterrordax - bones while on Ju''zaro''s quest'),
(1, 9167, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Frenzied Pterrordax - bones once his shop is open'),
(1, 6517, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Beast - bones while on Ju''zaro''s quest'),
(1, 6517, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Beast - bones once his shop is open'),
(1, 6518, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Lurker - bones while on Ju''zaro''s quest'),
(1, 6518, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Lurker - bones once his shop is open'),
(1, 6519, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Lord - bones while on Ju''zaro''s quest'),
(1, 6519, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Lord - bones once his shop is open'),
(1, 6527, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Creeper - bones while on Ju''zaro''s quest'),
(1, 6527, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tar Creeper - bones once his shop is open'),
(1, 6501, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Stegodon - bones while on Ju''zaro''s quest'),
(1, 6501, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Stegodon - bones once his shop is open'),
(1, 6502, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Plated Stegodon - bones while on Ju''zaro''s quest'),
(1, 6502, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Plated Stegodon - bones once his shop is open'),
(1, 6503, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Spiked Stegodon - bones while on Ju''zaro''s quest'),
(1, 6503, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Spiked Stegodon - bones once his shop is open'),
(1, 6504, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Thunderstomp Stegodon - bones while on Ju''zaro''s quest'),
(1, 6504, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Thunderstomp Stegodon - bones once his shop is open'),
(1, 6498, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Devilsaur - bones while on Ju''zaro''s quest'),
(1, 6498, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Devilsaur - bones once his shop is open'),
(1, 6581, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Matriarch - bones while on Ju''zaro''s quest'),
(1, 6581, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Ravasaur Matriarch - bones once his shop is open'),
(1, 6583, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Gruff - bones while on Ju''zaro''s quest'),
(1, 6583, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Gruff - bones once his shop is open'),
(1, 6584, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: King Mosh - bones while on Ju''zaro''s quest'),
(1, 6584, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: King Mosh - bones once his shop is open'),
(1, 9506001, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (dark) - bones while on Ju''zaro''s quest'),
(1, 9506001, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (dark) - bones once his shop is open'),
(1, 9506005, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (blue) - bones while on Ju''zaro''s quest'),
(1, 9506005, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (blue) - bones once his shop is open'),
(1, 9506006, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (green) - bones while on Ju''zaro''s quest'),
(1, 9506006, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (green) - bones once his shop is open'),
(1, 9506007, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (pale) - bones while on Ju''zaro''s quest'),
(1, 9506007, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (pale) - bones once his shop is open'),
(1, 9506008, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (brown) - bones while on Ju''zaro''s quest'),
(1, 9506008, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Tarborn Tyrant (brown) - bones once his shop is open'),
(1, 9506002, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Slate) - bones while on Ju''zaro''s quest'),
(1, 9506002, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Slate) - bones once his shop is open'),
(1, 9506003, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Amber) - bones while on Ju''zaro''s quest'),
(1, 9506003, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Amber) - bones once his shop is open'),
(1, 9506004, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Jade) - bones while on Ju''zaro''s quest'),
(1, 9506004, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Jade) - bones once his shop is open'),
(1, 9506009, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Crimson) - bones while on Ju''zaro''s quest'),
(1, 9506009, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Crimson) - bones once his shop is open'),
(1, 9506010, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Palehide) - bones while on Ju''zaro''s quest'),
(1, 9506010, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Palehide) - bones once his shop is open'),
(1, 9506011, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Cobalt) - bones while on Ju''zaro''s quest'),
(1, 9506011, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Cobalt) - bones once his shop is open'),
(1, 9506012, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Zandalari) - bones while on Ju''zaro''s quest'),
(1, 9506012, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Zandalari) - bones once his shop is open'),
(1, 9506013, 1963, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Golden) - bones while on Ju''zaro''s quest'),
(1, 9506013, 1963, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Zandalari Warbringer (Golden) - bones once his shop is open');

DELETE FROM `reference_loot_template` WHERE `Entry` = 9506000;
INSERT INTO `reference_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9506000, 23357, 0, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Primal Egg');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 10 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(10, 9506000, 23357, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg while on Ju''zaro''s quest'),
(10, 9506000, 23357, 0, 1, 8, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg once his shop is open');

-- ---------------------------------------------------------------------------------------------
-- Spawns
-- ---------------------------------------------------------------------------------------------

-- Heights are the client's terrain height at each spot plus 0.05. Ju'zaro's camp is on the
-- western rim of the Lakkari Tar Pits, at least 45 yards from any stock spawn, facing the pits.
DELETE FROM `pool_creature` WHERE `pool_entry` IN (9506001, 9506002);
DELETE FROM `pool_template` WHERE `entry` IN (9506001, 9506002);
DELETE FROM `creature` WHERE `guid` BETWEEN 9506000 AND 9506099;
DELETE FROM `gameobject` WHERE `guid` BETWEEN 9506000 AND 9506099;

INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `MovementType`, `Comment`) VALUES
(9506000, 9506000, 1, 1, 1, 1, -6536.00, -1130.00, -265.84, 4.52, 300, 0, 0, 'mod-primal-bones: Ju''zaro, rim of the Lakkari Tar Pits'),
(9506040, 9506001, 1, 1, 1, 0, -6320.00, -1266.00, -266.39, 3.60, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (dark), north rim of the Lakkari Tar Pits'),
(9506041, 9506005, 1, 1, 1, 0, -6320.00, -1266.00, -266.39, 3.60, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (blue), north rim of the Lakkari Tar Pits'),
(9506042, 9506006, 1, 1, 1, 0, -6320.00, -1266.00, -266.39, 3.60, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (green), north rim of the Lakkari Tar Pits'),
(9506043, 9506007, 1, 1, 1, 0, -6320.00, -1266.00, -266.39, 3.60, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (pale), north rim of the Lakkari Tar Pits'),
(9506044, 9506008, 1, 1, 1, 0, -6320.00, -1266.00, -266.39, 3.60, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (brown), north rim of the Lakkari Tar Pits'),
(9506045, 9506001, 1, 1, 1, 0, -6488.00, -1414.00, -266.45, 3.00, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (dark), north-east rim of the Lakkari Tar Pits'),
(9506046, 9506005, 1, 1, 1, 0, -6488.00, -1414.00, -266.45, 3.00, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (blue), north-east rim of the Lakkari Tar Pits'),
(9506047, 9506006, 1, 1, 1, 0, -6488.00, -1414.00, -266.45, 3.00, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (green), north-east rim of the Lakkari Tar Pits'),
(9506048, 9506007, 1, 1, 1, 0, -6488.00, -1414.00, -266.45, 3.00, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (pale), north-east rim of the Lakkari Tar Pits'),
(9506049, 9506008, 1, 1, 1, 0, -6488.00, -1414.00, -266.45, 3.00, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (brown), north-east rim of the Lakkari Tar Pits'),
(9506050, 9506001, 1, 1, 1, 0, -6700.00, -1432.00, -268.82, 1.20, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (dark), south rim of the Lakkari Tar Pits'),
(9506051, 9506005, 1, 1, 1, 0, -6700.00, -1432.00, -268.82, 1.20, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (blue), south rim of the Lakkari Tar Pits'),
(9506052, 9506006, 1, 1, 1, 0, -6700.00, -1432.00, -268.82, 1.20, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (green), south rim of the Lakkari Tar Pits'),
(9506053, 9506007, 1, 1, 1, 0, -6700.00, -1432.00, -268.82, 1.20, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (pale), south rim of the Lakkari Tar Pits'),
(9506054, 9506008, 1, 1, 1, 0, -6700.00, -1432.00, -268.82, 1.20, 10800, 10, 1, 'mod-primal-bones: Tarborn Tyrant (brown), south rim of the Lakkari Tar Pits'),
(9506020, 9506002, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), north-western jungle'),
(9506021, 9506003, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), north-western jungle'),
(9506022, 9506004, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), north-western jungle'),
(9506023, 9506009, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Crimson), north-western jungle'),
(9506024, 9506002, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), northern jungle'),
(9506025, 9506003, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), northern jungle'),
(9506026, 9506004, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), northern jungle'),
(9506027, 9506009, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Crimson), northern jungle'),
(9506028, 9506002, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), south-western stegodon fields'),
(9506029, 9506003, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), south-western stegodon fields'),
(9506030, 9506004, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), south-western stegodon fields'),
(9506031, 9506009, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Crimson), south-western stegodon fields'),
(9506032, 9506002, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), southern plains'),
(9506033, 9506003, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), southern plains'),
(9506034, 9506004, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), southern plains'),
(9506035, 9506009, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Crimson), southern plains'),
(9506036, 9506002, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), eastern marshes'),
(9506037, 9506003, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), eastern marshes'),
(9506038, 9506004, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), eastern marshes'),
(9506039, 9506009, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Crimson), eastern marshes'),
(9506055, 9506010, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Palehide), north-western jungle'),
(9506056, 9506010, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Palehide), northern jungle'),
(9506057, 9506010, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Palehide), south-western stegodon fields'),
(9506058, 9506010, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Palehide), southern plains'),
(9506059, 9506010, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Palehide), eastern marshes'),
(9506060, 9506011, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Cobalt), north-western jungle'),
(9506061, 9506011, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Cobalt), northern jungle'),
(9506062, 9506011, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Cobalt), south-western stegodon fields'),
(9506063, 9506011, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Cobalt), southern plains'),
(9506064, 9506011, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Cobalt), eastern marshes'),
(9506065, 9506012, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Zandalari), north-western jungle'),
(9506066, 9506012, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Zandalari), northern jungle'),
(9506067, 9506012, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Zandalari), south-western stegodon fields'),
(9506068, 9506012, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Zandalari), southern plains'),
(9506069, 9506012, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Zandalari), eastern marshes'),
(9506070, 9506013, 1, 1, 1, 1, -6864.70, -619.10, -271.31, 5.50, 3600, 15, 1, 'mod-primal-bones: Warbringer (Golden), north-western jungle'),
(9506071, 9506013, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Golden), northern jungle'),
(9506072, 9506013, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Golden), south-western stegodon fields'),
(9506073, 9506013, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Golden), southern plains'),
(9506074, 9506013, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Golden), eastern marshes');

-- One Tyrant at a time (three hours after a kill, any skin at any of its spots), and one
-- Warbringer at a time (an hour after a kill, any colour at any of its spots). Chance 0: all
-- equally likely.
INSERT INTO `pool_template` (`entry`, `max_limit`, `description`) VALUES
(9506001, 1, 'mod-primal-bones: Tarborn Tyrant, one skin and spot at a time'),
(9506002, 1, 'mod-primal-bones: Zandalari Warbringer, one colour and spot at a time');
INSERT INTO `pool_creature` (`guid`, `pool_entry`, `chance`, `description`) VALUES
(9506040, 9506001, 0, 'Tarborn Tyrant'),
(9506041, 9506001, 0, 'Tarborn Tyrant'),
(9506042, 9506001, 0, 'Tarborn Tyrant'),
(9506043, 9506001, 0, 'Tarborn Tyrant'),
(9506044, 9506001, 0, 'Tarborn Tyrant'),
(9506045, 9506001, 0, 'Tarborn Tyrant'),
(9506046, 9506001, 0, 'Tarborn Tyrant'),
(9506047, 9506001, 0, 'Tarborn Tyrant'),
(9506048, 9506001, 0, 'Tarborn Tyrant'),
(9506049, 9506001, 0, 'Tarborn Tyrant'),
(9506050, 9506001, 0, 'Tarborn Tyrant'),
(9506051, 9506001, 0, 'Tarborn Tyrant'),
(9506052, 9506001, 0, 'Tarborn Tyrant'),
(9506053, 9506001, 0, 'Tarborn Tyrant'),
(9506054, 9506001, 0, 'Tarborn Tyrant'),
(9506020, 9506002, 0, 'Zandalari Warbringer'),
(9506021, 9506002, 0, 'Zandalari Warbringer'),
(9506022, 9506002, 0, 'Zandalari Warbringer'),
(9506023, 9506002, 0, 'Zandalari Warbringer'),
(9506024, 9506002, 0, 'Zandalari Warbringer'),
(9506025, 9506002, 0, 'Zandalari Warbringer'),
(9506026, 9506002, 0, 'Zandalari Warbringer'),
(9506027, 9506002, 0, 'Zandalari Warbringer'),
(9506028, 9506002, 0, 'Zandalari Warbringer'),
(9506029, 9506002, 0, 'Zandalari Warbringer'),
(9506030, 9506002, 0, 'Zandalari Warbringer'),
(9506031, 9506002, 0, 'Zandalari Warbringer'),
(9506032, 9506002, 0, 'Zandalari Warbringer'),
(9506033, 9506002, 0, 'Zandalari Warbringer'),
(9506034, 9506002, 0, 'Zandalari Warbringer'),
(9506035, 9506002, 0, 'Zandalari Warbringer'),
(9506036, 9506002, 0, 'Zandalari Warbringer'),
(9506037, 9506002, 0, 'Zandalari Warbringer'),
(9506038, 9506002, 0, 'Zandalari Warbringer'),
(9506039, 9506002, 0, 'Zandalari Warbringer'),
(9506055, 9506002, 0, 'Zandalari Warbringer'),
(9506056, 9506002, 0, 'Zandalari Warbringer'),
(9506057, 9506002, 0, 'Zandalari Warbringer'),
(9506058, 9506002, 0, 'Zandalari Warbringer'),
(9506059, 9506002, 0, 'Zandalari Warbringer'),
(9506060, 9506002, 0, 'Zandalari Warbringer'),
(9506061, 9506002, 0, 'Zandalari Warbringer'),
(9506062, 9506002, 0, 'Zandalari Warbringer'),
(9506063, 9506002, 0, 'Zandalari Warbringer'),
(9506064, 9506002, 0, 'Zandalari Warbringer'),
(9506065, 9506002, 0, 'Zandalari Warbringer'),
(9506066, 9506002, 0, 'Zandalari Warbringer'),
(9506067, 9506002, 0, 'Zandalari Warbringer'),
(9506068, 9506002, 0, 'Zandalari Warbringer'),
(9506069, 9506002, 0, 'Zandalari Warbringer'),
(9506070, 9506002, 0, 'Zandalari Warbringer'),
(9506071, 9506002, 0, 'Zandalari Warbringer'),
(9506072, 9506002, 0, 'Zandalari Warbringer'),
(9506073, 9506002, 0, 'Zandalari Warbringer'),
(9506074, 9506002, 0, 'Zandalari Warbringer');

-- Ju'zaro's camp: a troll bonfire (a cooking fire for players too), bone piles, and the module's
-- own props: plain decoration (type 5) on stock client models, since the stock objects that use
-- these models are quest items, chests or traps. 9506000-9506099 are this module's.
DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9506000 AND 9506099;
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`, `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(9506000, 5, 7202, 'Raptor Nest', '', '', '', 1, '', '', 0),
(9506001, 5, 321, 'Primal Eggs', '', '', '', 0.8, '', '', 0),
(9506002, 5, 9259, 'Primal Eggs', '', '', '', 0.8, '', '', 0),
(9506003, 5, 7597, 'Ribcage', '', '', '', 1, '', '', 0),
(9506004, 5, 653, 'Tiki Head', '', '', '', 1, '', '', 0),
(9506005, 5, 7535, 'Zandalari War Drum', '', '', '', 1, '', '', 0),
(9506006, 5, 7493, 'Supply Sacks', '', '', '', 1, '', '', 0),
(9506007, 5, 7954, 'Bat Totem', '', '', '', 1, '', '', 0);

INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9506000, 20977, 1, 1, 1, -6534.30, -1134.40, -265.22, 0.00, 0, 0, 0.000000, 1.000000, 300, 100, 1, 'mod-primal-bones: Ju''zaro''s troll bonfire'),
(9506001, 181191, 1, 1, 1, -6540.12, -1130.22, -265.63, 0.24, 0, 0, 0.119101, 0.992882, 300, 100, 1, 'mod-primal-bones: bone pile, Ju''zaro''s camp'),
(9506002, 181193, 1, 1, 1, -6542.46, -1131.81, -265.21, 3.62, 0, 0, 0.971295, -0.237878, 300, 100, 1, 'mod-primal-bones: spine, Ju''zaro''s camp'),
(9506003, 9506000, 1, 1, 1, -6531.20, -1128.89, -266.29, 5.12, 0, 0, 0.548539, -0.836125, 300, 100, 1, 'mod-primal-bones: raptor nest, Ju''zaro''s camp'),
(9506004, 9506001, 1, 1, 1, -6531.20, -1128.89, -266.29, 0.14, 0, 0, 0.069329, 0.997594, 300, 100, 1, 'mod-primal-bones: primal eggs in the nest, Ju''zaro''s camp'),
(9506005, 9506002, 1, 1, 1, -6529.82, -1130.68, -266.13, 1.34, 0, 0, 0.620503, 0.784204, 300, 100, 1, 'mod-primal-bones: primal eggs, Ju''zaro''s camp'),
(9506006, 9506003, 1, 1, 1, -6538.22, -1120.41, -267.53, 5.92, 0, 0, 0.179635, -0.983733, 300, 100, 1, 'mod-primal-bones: ribcage behind Ju''zaro''s camp'),
(9506007, 9506004, 1, 1, 1, -6539.50, -1134.93, -264.78, 4.52, 0, 0, 0.771131, -0.636676, 300, 100, 1, 'mod-primal-bones: tiki head, Ju''zaro''s camp'),
(9506008, 9506005, 1, 1, 1, -6540.43, -1127.62, -266.15, 4.82, 0, 0, 0.667328, -0.744764, 300, 100, 1, 'mod-primal-bones: war drum, Ju''zaro''s camp'),
(9506009, 9506006, 1, 1, 1, -6533.86, -1126.85, -266.48, 0.64, 0, 0, 0.313982, 0.949429, 300, 100, 1, 'mod-primal-bones: supply sacks, Ju''zaro''s camp'),
(9506010, 9506007, 1, 1, 1, -6534.38, -1137.44, -264.81, 4.52, 0, 0, 0.771131, -0.636676, 300, 100, 1, 'mod-primal-bones: bat totem, Ju''zaro''s camp');
