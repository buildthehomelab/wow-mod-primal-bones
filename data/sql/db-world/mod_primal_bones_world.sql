-- mod-primal-bones: the Zandalar bonewright Ju'zaro, the ten-thousand-bone rite, and the beasts of
-- Un'Goro Crater that feed it.
--
--   item 1963        Primal Bone. Repurposes Blizzard's unused "Deprecated Bone Chips" row: the
--                    client already has a bone icon for that entry (INV_Misc_Bone_07), a new entry
--                    would show a question mark. Soulbound, stacks to 9,999, at most 9,999.
--   item 23357       Primal Egg (repurposed "NPC Equip 23357", egg icon). Hatches after three days,
--                    offline time included: the module's item script swaps it for
--   item 20798       Hatched Primal Egg (repurposed "NPC Equip 20798", egg icon), which opens.
--   creature 9506000 Ju'zaro, Zandalar Bonewright, camped on the rim of the Lakkari Tar Pits.
--   quests 9506000.. The Ten-Thousandth Bone (9,999 bones: Bone-White Primal Raptor), and 15 more
--   9506015          that trade bones for the other primal raptors, a direhorn and pets. Each can
--                    be done once. They all take bones from the same pile.
--   creatures        Tarborn Tyrant, rare elite primal devilsaur, one entry per striped skin, each
--   9506001, 9506005 with its own mount; three spawn spots, one Tyrant at a time.
--   ..9506008
--   creature 9506002 Zandalari Warbringer on a Slate, Amber or Jade Primordial Direhorn, rare
--   ..9506004        elite; five spawn spots and three colours, one Warbringer at a time.
--
-- Bones and eggs only drop for a player with one of Ju'zaro's quests in the quest log. Bones are a
-- quest objective (QuestRequired loot); eggs are conditioned on the quests being taken.
--
-- Needs the item and creature rows of wow-mod-retail-collection (the rewards, 400000+ and 410000+)
-- and the looks of wow-mod-retail-library (the direhorns the Warbringers ride and the Tyrant's
-- striped devilsaur, displays 247249/247271/247272/247273/276972).
--
-- This module's ids: creature, quest, npc_text, gossip menu, reference loot, pool and spawn guids
-- 9506000-9506099. Stock rows changed: the three repurposed items above, and new loot rows on 22
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

-- What hatches: one of the three primal raptor mounts (3% each), one of the six Zandalari raptor
-- pets (6% each), or else a heap of bones (the remaining 55%).
DELETE FROM `item_loot_template` WHERE `Entry` = 20798;
INSERT INTO `item_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(20798, 400538, 0, 3, 0, 1, 1, 1, 1, 'mod-primal-bones: Red Primal Raptor'),
(20798, 400539, 0, 3, 0, 1, 1, 1, 1, 'mod-primal-bones: Black Primal Raptor'),
(20798, 400540, 0, 3, 0, 1, 1, 1, 1, 'mod-primal-bones: Green Primal Raptor'),
(20798, 411180, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Zandalari Kneebiter'),
(20798, 411211, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Zandalari Anklerender'),
(20798, 411212, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Zandalari Footslasher'),
(20798, 411213, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Zandalari Toenibbler'),
(20798, 412413, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Zandalari Shinchomper'),
(20798, 412537, 0, 6, 0, 1, 1, 1, 1, 'mod-primal-bones: Baby Zandalari Raptor'),
(20798, 1963, 0, 0, 0, 1, 1, 100, 200, 'mod-primal-bones: Primal Bone');

-- ---------------------------------------------------------------------------------------------
-- Ju'zaro
-- ---------------------------------------------------------------------------------------------

-- The Zandalarian Emissary's model (15210) and weapon. Faction 35: friendly to everyone.
-- npcflag 3: gossip and quests. unit_flags 768: nothing attacks him.
DELETE FROM `creature_template` WHERE `entry` = 9506000;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `HealthModifier`, `flags_extra`) VALUES
(9506000, 'Ju''zaro', 'Zandalar Bonewright', 9506000, 60, 60, 35, 3, 1, 1.14286, 2000, 2000, 1, 768, 2048, 7, 3, 2);

DELETE FROM `creature_template_model` WHERE `CreatureID` = 9506000;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9506000, 0, 15210, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` = 9506000;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9506000, 1, 13336, 0, 0, 0);

-- What he says depends on the bones in your bags. Exactly one of the texts below fits any player
-- (the conditions further down), so the order the core reads them in doesn't matter.
DELETE FROM `npc_text` WHERE `ID` BETWEEN 9506000 AND 9506005;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `Probability0`) VALUES
(9506000, 'Da crater would eat you alive, little one. Da devilsaurs don''t care how brave you be.$B$BCome back when you be strong enough to stand in da tar and walk out again.', 'Da crater would eat you alive, little one. Da devilsaurs don''t care how brave you be.$B$BCome back when you be strong enough to stand in da tar and walk out again.', 1),
(9506001, 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BDa beasts of dis crater carry da oldest blood on Azeroth. Bring Ju''zaro dere bones and da tar gives you somethin'' back.', 'Da tar keeps everything, mon. Bones, beasts, secrets. Ju''zaro just be here to take some of it back.$B$BDa beasts of dis crater carry da oldest blood on Azeroth. Bring Ju''zaro dere bones and da tar gives you somethin'' back.', 1),
(9506002, 'A quarter of da rite already. Ju''zaro can hear da tar listenin'' now.', 'A quarter of da rite already. Ju''zaro can hear da tar listenin'' now.', 1),
(9506003, 'Half. Somethin'' under da pitch be stirrin'', $N. Somethin'' pale.', 'Half. Somethin'' under da pitch be stirrin'', $N. Somethin'' pale.', 1),
(9506004, 'So close. Da old bones be whisperin'' your name in da night. Ju''zaro hears it too.', 'So close. Da old bones be whisperin'' your name in da night. Ju''zaro hears it too.', 1),
(9506005, 'Dat be all of dem! Give dem here, quick, before da egg hatches without you.', 'Dat be all of dem! Give dem here, quick, before da egg hatches without you.', 1);

DELETE FROM `gossip_menu` WHERE `MenuID` = 9506000;
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9506000, 9506000), (9506000, 9506001), (9506000, 9506002), (9506000, 9506003), (9506000, 9506004), (9506000, 9506005);

-- Source type 14 (gossip menu text). Type 27: level, compared 2 (lower) or 3 (at least).
-- Type 2: that many Primal Bones in the bags. NegativeCondition 1 turns a row around.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 14 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(14, 9506000, 9506000, 0, 0, 27, 0, 60, 2, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, below level 60'),
(14, 9506000, 9506001, 0, 0, 27, 0, 60, 3, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, level 60'),
(14, 9506000, 9506001, 0, 0, 2, 0, 1963, 2500, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 2500 bones'),
(14, 9506000, 9506002, 0, 0, 2, 0, 1963, 2500, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 2500 bones'),
(14, 9506000, 9506002, 0, 0, 2, 0, 1963, 5000, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 5000 bones'),
(14, 9506000, 9506003, 0, 0, 2, 0, 1963, 5000, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 5000 bones'),
(14, 9506000, 9506003, 0, 0, 2, 0, 1963, 7500, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 7500 bones'),
(14, 9506000, 9506004, 0, 0, 2, 0, 1963, 7500, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 7500 bones'),
(14, 9506000, 9506004, 0, 0, 2, 0, 1963, 9999, 0, 1, 0, 0, '', 'mod-primal-bones: Ju''zaro, fewer than 9999 bones'),
(14, 9506000, 9506005, 0, 0, 2, 0, 1963, 9999, 0, 0, 0, 0, '', 'mod-primal-bones: Ju''zaro, 9999 bones');

-- ---------------------------------------------------------------------------------------------
-- The quests
-- ---------------------------------------------------------------------------------------------

-- Level 60, filed under Un'Goro Crater (490), no experience or money. Flags 64: can be done in
-- a raid group, so bones and eggs still drop for players in one.
DELETE FROM `quest_template` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `Flags`, `RequiredItemId1`, `RequiredItemCount1`, `RewardItem1`, `RewardAmount1`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `VerifiedBuild`) VALUES
(9506000, 2, 60, 60, 490, 0, 64, 1963, 9999, 400537, 1,
 'The Ten-Thousandth Bone',
 'Bring 9,999 Primal Bones to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.',
 'You smell dat, $C? Tar, and old blood. Dis crater be da oldest garden on Azeroth. Da titans planted it, and da beasts here still carry da first bloodlines in dere bones.$B$BDa Zandalar been raisin'' raptors since before your kingdoms had names. But a primal raptor... dat takes a rite. Ten thousand bones of da crater''s beasts, laid in da tar where da old ones sank.$B$BBring Ju''zaro nine thousand, nine hundred and ninety-nine of dem. Da last bone? Dat one grows inside da egg. When it hatches it be white as all da rest, and it be yours.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506001, 2, 60, 60, 490, 0, 64, 1963, 3333, 400538, 1,
 'Red as the Fire Plume',
 'Bring 3,333 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Not every raptor be needin'' da whole rite. A third of it - three thousand, three hundred and thirty-three bones - and da tar gives up a red one, hot as da Fire Plume.$B$BBut every bone you spend here be a bone da white raptor waits for. Ju''zaro only says it once.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506002, 2, 60, 60, 490, 0, 64, 1963, 3333, 400539, 1,
 'Black as the Tar',
 'Bring 3,333 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Some eggs sink deeper than others. Dey come up black as da pit dey slept in, and dey never forget da dark.$B$BThree thousand, three hundred and thirty-three bones, $N. Dat be da price of a third of da rite.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506003, 2, 60, 60, 490, 0, 64, 1963, 3333, 400540, 1,
 'Green as the Crater',
 'Bring 3,333 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da green ones hatch where da jungle grows over da tar. Dey be fast, and dey be hungry, and dey go anywhere da vines go.$B$BThree thousand, three hundred and thirty-three bones for a third of da rite.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506004, 2, 60, 60, 490, 0, 64, 1963, 3333, 401179, 1,
 'The Palehide',
 'Bring 3,333 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da direhorns be older than da raptors, $C. Older than da Zandalar, maybe. Dere be a palehide calf in da shallows dat lost its herd to a devilsaur, and it follows Ju''zaro around da camp like a lost kitten.$B$BIt needs a rider dat can keep it fed. Three thousand, three hundred and thirty-three bones says you can.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506005, 2, 60, 60, 490, 0, 64, 1963, 500, 411180, 1,
 'A Kneebiter of Your Own',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Ju''zaro keeps a clutch of little ones from Zandalar. Dis one bites knees. It bit Ju''zaro''s knees all da way across da sea.$B$BFive hundred bones and it be biting yours instead.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506006, 2, 60, 60, 490, 0, 64, 1963, 500, 411211, 1,
 'The Anklerender',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Dis one goes for da ankles. Smarter than da kneebiter: you can''t run without ankles.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506007, 2, 60, 60, 490, 0, 64, 1963, 500, 411212, 1,
 'The Footslasher',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Toes, ankles, knees... dis one does not care. It be slashin'' whatever be nearest da ground.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506008, 2, 60, 60, 490, 0, 64, 1963, 500, 411213, 1,
 'The Toenibbler',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da gentle one of da clutch. It only nibbles. Mostly.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506009, 2, 60, 60, 490, 0, 64, 1963, 500, 412413, 1,
 'The Shinchomper',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Ju''zaro will not lie to you: dis one be trouble. Da shins never see it comin''.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506010, 2, 60, 60, 490, 0, 64, 1963, 500, 412537, 1,
 'A Baby Raptor',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da youngest of da Zandalari clutch. It ain''t learned what to bite yet, so it bites everything.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506011, 2, 60, 60, 490, 0, 64, 1963, 500, 411200, 1,
 'A Pygmy Direhorn',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Not every direhorn grows big. Dis one be stayin'' small forever, and it be very angry about it.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506012, 2, 60, 60, 490, 0, 64, 1963, 500, 412412, 1,
 'A Tiny Direhorn',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Found dis one sleepin'' in a stegodon''s footprint. Da footprint be bigger than it is.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506013, 2, 60, 60, 490, 0, 64, 1963, 500, 411184, 1,
 'A Stunted Direhorn',
 'Bring 500 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da herd left dis one behind. Stubby legs, stubby horns, all da stubbornness of a full-grown direhorn.$B$BFive hundred bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506014, 2, 60, 60, 490, 0, 64, 1963, 250, 412197, 1,
 'A Direhorn Hatchling',
 'Bring 250 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Ju''zaro found dis one curled up inside an old direhorn skull by da tar, wearin'' it like a shell. It still will not take it off.$B$BTwo hundred and fifty bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0),
(9506015, 2, 60, 60, 490, 0, 64, 1963, 250, 410504, 1,
 'A Diemetradon Hatchling',
 'Bring 250 Primal Bones to Ju''zaro at the Lakkari Tar Pits.',
 'Da sail-backs warm demselves on da hot rocks by da tar. Dis little one fell asleep on Ju''zaro''s fire and would not leave.$B$BTwo hundred and fifty bones.',
 'Return to Ju''zaro at the Lakkari Tar Pits in Un''Goro Crater.', 0);

DELETE FROM `quest_request_items` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`, `VerifiedBuild`) VALUES
(9506000, 1, 1, 'Every beast in dis crater be carryin'' bones, mon. Only a fool leaves dem in da dirt.', 0),
(9506001, 1, 1, 'A third of a rite be still a rite, mon.', 0),
(9506002, 1, 1, 'Da tar keeps its eggs close. Bones loosen its grip.', 0),
(9506003, 1, 1, 'Da jungle be patient. Ju''zaro be less patient.', 0),
(9506004, 1, 1, 'Da palehide be eatin'' Ju''zaro''s tent pegs again.', 0),
(9506005, 1, 1, 'Watch your knees, mon.', 0),
(9506006, 1, 1, 'It be waitin'' under da table again.', 0),
(9506007, 1, 1, 'Keep your boots on around dis one.', 0),
(9506008, 1, 1, 'Nibble, nibble.', 0),
(9506009, 1, 1, 'Ju''zaro be wearin'' greaves now. Ask Ju''zaro why.', 0),
(9506010, 1, 1, 'It chewed through da bone sack again.', 0),
(9506011, 1, 1, 'Small horns, big temper.', 0),
(9506012, 1, 1, 'It be nappin''. Again.', 0),
(9506013, 1, 1, 'It headbutted da bone pile over. Twice.', 0),
(9506014, 1, 1, 'It be hidin'' in da skull again.', 0),
(9506015, 1, 1, 'It be on da fire again. It likes da fire.', 0);

DELETE FROM `quest_offer_reward` WHERE `ID` BETWEEN 9506000 AND 9506015;
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `Emote2`, `Emote3`, `Emote4`, `EmoteDelay1`, `EmoteDelay2`, `EmoteDelay3`, `EmoteDelay4`, `RewardText`, `VerifiedBuild`) VALUES
(9506000, 4, 0, 0, 0, 0, 0, 0, 0, 'Nine thousand, nine hundred and ninety-nine. Ju''zaro counted dem twice.$B$BListen... da tar be bubblin''. Da egg be crackin'' already. See? Pale as da moon, and already lookin'' at you like you owe it dinner.$B$BRide well, $N. Da Zandalar will hear of dis.', 0),
(9506001, 1, 0, 0, 0, 0, 0, 0, 0, 'Red as da mountain''s blood. Dis one bites, so keep your fingers where it can see dem.', 0),
(9506002, 1, 0, 0, 0, 0, 0, 0, 0, 'Black as da tar. It hatched quiet, and it be watchin'' you already. Dat be a good sign.', 0),
(9506003, 1, 0, 0, 0, 0, 0, 0, 0, 'Green as da crater. Take it out where da ferns be tall. It be wantin'' to run.', 0),
(9506004, 1, 0, 0, 0, 0, 0, 0, 0, 'Da palehide be yours. Feed it well and it carries you through a wall, if you be askin'' it nicely.', 0),
(9506005, 1, 0, 0, 0, 0, 0, 0, 0, 'Here. He be your problem now.', 0),
(9506006, 1, 0, 0, 0, 0, 0, 0, 0, 'Take it. Ju''zaro be walkin'' normal again by sunset.', 0),
(9506007, 1, 0, 0, 0, 0, 0, 0, 0, 'It likes you. It only slashed you a little.', 0),
(9506008, 1, 0, 0, 0, 0, 0, 0, 0, 'Here. Do not fall asleep without boots.', 0),
(9506009, 1, 0, 0, 0, 0, 0, 0, 0, 'Go on, take it. Quick, before it remembers Ju''zaro.', 0),
(9506010, 1, 0, 0, 0, 0, 0, 0, 0, 'It be learnin'' fast. Teach it to bite da right people.', 0),
(9506011, 1, 0, 0, 0, 0, 0, 0, 0, 'Here. Keep it away from da big ones; it starts fights it cannot finish.', 0),
(9506012, 1, 0, 0, 0, 0, 0, 0, 0, 'Careful where you step. It sleeps everywhere.', 0),
(9506013, 1, 0, 0, 0, 0, 0, 0, 0, 'A good little beast. It keeps up, if you walk slow.', 0),
(9506014, 1, 0, 0, 0, 0, 0, 0, 0, 'Here. Da skull comes with it, apparently.', 0),
(9506015, 1, 0, 0, 0, 0, 0, 0, 0, 'Keep it warm, $N. It sulks when it be cold.', 0);

DELETE FROM `creature_queststarter` WHERE `quest` BETWEEN 9506000 AND 9506015;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9506000, 9506000),
(9506000, 9506001),
(9506000, 9506002),
(9506000, 9506003),
(9506000, 9506004),
(9506000, 9506005),
(9506000, 9506006),
(9506000, 9506007),
(9506000, 9506008),
(9506000, 9506009),
(9506000, 9506010),
(9506000, 9506011),
(9506000, 9506012),
(9506000, 9506013),
(9506000, 9506014),
(9506000, 9506015);

DELETE FROM `creature_questender` WHERE `quest` BETWEEN 9506000 AND 9506015;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9506000, 9506000),
(9506000, 9506001),
(9506000, 9506002),
(9506000, 9506003),
(9506000, 9506004),
(9506000, 9506005),
(9506000, 9506006),
(9506000, 9506007),
(9506000, 9506008),
(9506000, 9506009),
(9506000, 9506010),
(9506000, 9506011),
(9506000, 9506012),
(9506000, 9506013),
(9506000, 9506014),
(9506000, 9506015);

-- ---------------------------------------------------------------------------------------------
-- The rares
-- ---------------------------------------------------------------------------------------------

-- Tarborn Tyrants: primal devilsaurs that crawled out of the tar, built like King Mosh (rank 2,
-- rare elite; same health, damage and abilities). One entry for each of retail's five striped
-- primal devilsaur skins, so each drops its own mount:
--   9506001  dark  (display 247249): Cobalt Primordial Direhorn
--   9506005  blue  (display 247271): Zandalari Direhorn
--   9506006  green (display 247272): Savage Raptor
--   9506007  pale  (display 247273): Swift Albino Raptor
--   9506008  brown (display 276972): Golden Primal Direhorn
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
-- (247717). visibilityDistanceType 3: seen from further away, like other large rares.
DELETE FROM `creature_template` WHERE `entry` BETWEEN 9506002 AND 9506004;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `speed_walk`, `speed_run`, `rank`, `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `lootid`, `mingold`, `maxgold`, `AIName`, `HealthModifier`, `RegenHealth`) VALUES
(9506002, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506002, 2000, 4000, 'SmartAI', 10, 1),
(9506003, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506003, 2000, 4000, 'SmartAI', 10, 1),
(9506004, 'Zandalari Warbringer', NULL, 60, 60, 14, 1.6, 1.71429, 2, 6, 2000, 2000, 1, 0, 2048, 7, 9506004, 2000, 4000, 'SmartAI', 10, 1);

DELETE FROM `creature_template_model` WHERE `CreatureID` BETWEEN 9506002 AND 9506004;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES
(9506002, 0, 15004, 1, 1, 0),
(9506003, 0, 15004, 1, 1, 0),
(9506004, 0, 15004, 1, 1, 0);

DELETE FROM `creature_equip_template` WHERE `CreatureID` BETWEEN 9506002 AND 9506004;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(9506002, 1, 18002, 0, 18019, 0),
(9506003, 1, 18002, 0, 18019, 0),
(9506004, 1, 18002, 0, 18019, 0);

DELETE FROM `creature_template_addon` WHERE `entry` BETWEEN 9506002 AND 9506004;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`) VALUES
(9506002, 0, 247715, 0, 1, 0, 3, NULL),
(9506003, 0, 247718, 0, 1, 0, 3, NULL),
(9506004, 0, 247717, 0, 1, 0, 3, NULL);

-- Both announce themselves to the whole crater when they appear (TextRange 2: zone), so players
-- know one is up somewhere. Type 16: monster emote.
DELETE FROM `creature_text` WHERE `CreatureID` BETWEEN 9506001 AND 9506008;
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
(9506004, 1, 0, 'Da Zandalar take what dey want!', 12, 0, 100, 0, 0, 0, 0, 0, 'mod-primal-bones: Warbringer aggro');

-- Tyrant: King Mosh's three attacks, plus the two lines above. Warbringers: Cleave, Mortal
-- Strike and a direhorn Thunderclap.
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` BETWEEN 9506001 AND 9506008;
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
(9506004, 0, 4, 0, 0, 0, 100, 0, 12000, 15000, 15000, 20000, 0, 0, 11, 15548, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Zandalari Warbringer - In Combat - Cast Thunderclap');

-- ---------------------------------------------------------------------------------------------
-- Loot
-- ---------------------------------------------------------------------------------------------

-- Bones: QuestRequired 1, so only players who still need bones for one of Ju'zaro's quests see
-- them. About 4-5 a kill from the crater's beasts, 15-25 from its elites and far more from the
-- rares: roughly twelve hours of hunting for 9,999 alone. Eggs: a reference (below) that only
-- players with one of the quests taken can see.
DELETE FROM `creature_loot_template` WHERE `Item` IN (1963, 9506000) AND `Entry` IN (6505, 6506, 6507, 6508, 9162, 9163, 9164, 9165, 9166, 9167, 6517, 6518, 6519, 6527, 6501, 6502, 6503, 6504, 6498, 6581, 6583, 6584);
DELETE FROM `creature_loot_template` WHERE `Entry` BETWEEN 9506001 AND 9506008;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(6505, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur - Primal Bone'),
(6505, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur - Primal Egg'),
(6506, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur Runner - Primal Bone'),
(6506, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Runner - Primal Egg'),
(6507, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Ravasaur Hunter - Primal Bone'),
(6507, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Hunter - Primal Egg'),
(6508, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Venomhide Ravasaur - Primal Bone'),
(6508, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Venomhide Ravasaur - Primal Egg'),
(9162, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Young Diemetradon - Primal Bone'),
(9162, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Young Diemetradon - Primal Egg'),
(9163, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Diemetradon - Primal Bone'),
(9163, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Diemetradon - Primal Egg'),
(9164, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Elder Diemetradon - Primal Bone'),
(9164, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Elder Diemetradon - Primal Egg'),
(9165, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Fledgling Pterrordax - Primal Bone'),
(9165, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Fledgling Pterrordax - Primal Egg'),
(9166, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Pterrordax - Primal Bone'),
(9166, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Pterrordax - Primal Egg'),
(9167, 1963, 0, 100, 1, 1, 0, 3, 6, 'mod-primal-bones: Frenzied Pterrordax - Primal Bone'),
(9167, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Frenzied Pterrordax - Primal Egg'),
(6517, 1963, 0, 100, 1, 1, 0, 2, 4, 'mod-primal-bones: Tar Beast - Primal Bone'),
(6517, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Beast - Primal Egg'),
(6518, 1963, 0, 100, 1, 1, 0, 2, 4, 'mod-primal-bones: Tar Lurker - Primal Bone'),
(6518, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Lurker - Primal Egg'),
(6519, 1963, 0, 100, 1, 1, 0, 2, 4, 'mod-primal-bones: Tar Lord - Primal Bone'),
(6519, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Lord - Primal Egg'),
(6527, 1963, 0, 100, 1, 1, 0, 2, 4, 'mod-primal-bones: Tar Creeper - Primal Bone'),
(6527, 9506000, 9506000, 0.5, 0, 1, 0, 1, 1, 'mod-primal-bones: Tar Creeper - Primal Egg'),
(6501, 1963, 0, 100, 1, 1, 0, 15, 25, 'mod-primal-bones: Stegodon - Primal Bone'),
(6501, 9506000, 9506000, 2, 0, 1, 0, 1, 1, 'mod-primal-bones: Stegodon - Primal Egg'),
(6502, 1963, 0, 100, 1, 1, 0, 15, 25, 'mod-primal-bones: Plated Stegodon - Primal Bone'),
(6502, 9506000, 9506000, 2, 0, 1, 0, 1, 1, 'mod-primal-bones: Plated Stegodon - Primal Egg'),
(6503, 1963, 0, 100, 1, 1, 0, 15, 25, 'mod-primal-bones: Spiked Stegodon - Primal Bone'),
(6503, 9506000, 9506000, 2, 0, 1, 0, 1, 1, 'mod-primal-bones: Spiked Stegodon - Primal Egg'),
(6504, 1963, 0, 100, 1, 1, 0, 15, 25, 'mod-primal-bones: Thunderstomp Stegodon - Primal Bone'),
(6504, 9506000, 9506000, 2, 0, 1, 0, 1, 1, 'mod-primal-bones: Thunderstomp Stegodon - Primal Egg'),
(6498, 1963, 0, 100, 1, 1, 0, 15, 25, 'mod-primal-bones: Devilsaur - Primal Bone'),
(6498, 9506000, 9506000, 2, 0, 1, 0, 1, 1, 'mod-primal-bones: Devilsaur - Primal Egg'),
(6581, 1963, 0, 100, 1, 1, 0, 50, 80, 'mod-primal-bones: Ravasaur Matriarch - Primal Bone'),
(6581, 9506000, 9506000, 25, 0, 1, 0, 1, 1, 'mod-primal-bones: Ravasaur Matriarch - Primal Egg'),
(6583, 1963, 0, 100, 1, 1, 0, 100, 150, 'mod-primal-bones: Gruff - Primal Bone'),
(6583, 9506000, 9506000, 25, 0, 1, 0, 1, 1, 'mod-primal-bones: Gruff - Primal Egg'),
(6584, 1963, 0, 100, 1, 1, 0, 150, 250, 'mod-primal-bones: King Mosh - Primal Bone'),
(6584, 9506000, 9506000, 25, 0, 1, 0, 1, 1, 'mod-primal-bones: King Mosh - Primal Egg'),
(9506001, 1963, 0, 100, 1, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (dark) - Primal Bone'),
(9506001, 9506000, 9506000, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (dark) - Primal Egg'),
(9506005, 1963, 0, 100, 1, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (blue) - Primal Bone'),
(9506005, 9506000, 9506000, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (blue) - Primal Egg'),
(9506006, 1963, 0, 100, 1, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (green) - Primal Bone'),
(9506006, 9506000, 9506000, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (green) - Primal Egg'),
(9506007, 1963, 0, 100, 1, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (pale) - Primal Bone'),
(9506007, 9506000, 9506000, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (pale) - Primal Egg'),
(9506008, 1963, 0, 100, 1, 1, 0, 200, 250, 'mod-primal-bones: Tarborn Tyrant (brown) - Primal Bone'),
(9506008, 9506000, 9506000, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (brown) - Primal Egg'),
(9506002, 1963, 0, 100, 1, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Slate) - Primal Bone'),
(9506002, 9506000, 9506000, 50, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Slate) - Primal Egg'),
(9506003, 1963, 0, 100, 1, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Amber) - Primal Bone'),
(9506003, 9506000, 9506000, 50, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Amber) - Primal Egg'),
(9506004, 1963, 0, 100, 1, 1, 0, 60, 100, 'mod-primal-bones: Zandalari Warbringer (Jade) - Primal Bone'),
(9506004, 9506000, 9506000, 50, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer (Jade) - Primal Egg'),
(9506001, 400533, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (dark) - Cobalt Primordial Direhorn'),
(9506005, 401038, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (blue) - Zandalari Direhorn'),
(9506006, 400418, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (green) - Savage Raptor'),
(9506007, 401180, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (pale) - Swift Albino Raptor'),
(9506008, 400545, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Tarborn Tyrant (brown) - Golden Primal Direhorn'),
(9506002, 400535, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Slate Primordial Direhorn'),
(9506003, 400534, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Amber Primordial Direhorn'),
(9506004, 400536, 0, 10, 0, 1, 0, 1, 1, 'mod-primal-bones: Zandalari Warbringer - Jade Primordial Direhorn');

DELETE FROM `reference_loot_template` WHERE `Entry` = 9506000;
INSERT INTO `reference_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(9506000, 23357, 0, 100, 0, 1, 0, 1, 1, 'mod-primal-bones: Primal Egg');

-- Source type 10 (reference loot): any one of Ju'zaro's quests in the log (type 9, quest taken),
-- one ElseGroup each.
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 10 AND `SourceGroup` = 9506000;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(10, 9506000, 23357, 0, 0, 9, 0, 9506000, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 1, 9, 0, 9506001, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 2, 9, 0, 9506002, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 3, 9, 0, 9506003, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 4, 9, 0, 9506004, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 5, 9, 0, 9506005, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 6, 9, 0, 9506006, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 7, 9, 0, 9506007, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 8, 9, 0, 9506008, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 9, 9, 0, 9506009, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 10, 9, 0, 9506010, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 11, 9, 0, 9506011, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 12, 9, 0, 9506012, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 13, 9, 0, 9506013, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 14, 9, 0, 9506014, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest'),
(10, 9506000, 23357, 0, 15, 9, 0, 9506015, 0, 0, 0, 0, 0, '', 'mod-primal-bones: Primal Egg needs a bone quest');

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
(9506023, 9506002, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), northern jungle'),
(9506024, 9506003, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), northern jungle'),
(9506025, 9506004, 1, 1, 1, 1, -6513.50, -749.10, -270.11, 4.70, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), northern jungle'),
(9506026, 9506002, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), south-western stegodon fields'),
(9506027, 9506003, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), south-western stegodon fields'),
(9506028, 9506004, 1, 1, 1, 1, -7685.70, -908.80, -269.62, 1.00, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), south-western stegodon fields'),
(9506029, 9506002, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), southern plains'),
(9506030, 9506003, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), southern plains'),
(9506031, 9506004, 1, 1, 1, 1, -7823.70, -1615.00, -268.24, 1.60, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), southern plains'),
(9506032, 9506002, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Slate), eastern marshes'),
(9506033, 9506003, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Amber), eastern marshes'),
(9506034, 9506004, 1, 1, 1, 1, -6782.50, -2216.20, -271.93, 3.10, 3600, 15, 1, 'mod-primal-bones: Warbringer (Jade), eastern marshes');

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
(9506034, 9506002, 0, 'Zandalari Warbringer');

-- Ju'zaro's camp: a campfire (a cooking fire for players too) and a few bone piles.
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`) VALUES
(9506000, 20977, 1, 1, 1, -6534.30, -1134.40, -265.22, 0.00, 0, 0, 0.000000, 1.000000, 300, 100, 1, 'mod-primal-bones: Ju''zaro''s troll bonfire'),
(9506001, 184108, 1, 1, 1, -6531.27, -1105.45, -269.96, 5.72, 0, 0, 0.276947, -0.960885, 300, 100, 1, 'mod-primal-bones: dragon skeleton behind Ju''zaro''s camp'),
(9506002, 181191, 1, 1, 1, -6540.12, -1130.22, -265.63, 0.24, 0, 0, 0.119101, 0.992882, 300, 100, 1, 'mod-primal-bones: bone pile, Ju''zaro''s camp'),
(9506003, 181192, 1, 1, 1, -6530.71, -1128.98, -266.31, 5.22, 0, 0, 0.506064, -0.862496, 300, 100, 1, 'mod-primal-bones: bone pile, Ju''zaro''s camp'),
(9506004, 181193, 1, 1, 1, -6542.46, -1131.81, -265.21, 3.62, 0, 0, 0.971295, -0.237878, 300, 100, 1, 'mod-primal-bones: spine, Ju''zaro''s camp');
