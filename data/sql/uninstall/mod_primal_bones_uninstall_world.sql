-- mod-primal-bones: undo the module's world database changes. Run it by hand on the world
-- database after removing the module. It isn't applied automatically: AzerothCore only runs the
-- module's db-world folder.
--
-- Removes Ju'zaro, his quest, shop, prices and camp (with its props), the Tarborn Tyrants and the
-- Zandalari Warbringers with their spawns and pools, the bone and egg loot on Un'Goro's creatures,
-- and puts the three repurposed items back the way stock AzerothCore has them. Bones and eggs that players already
-- own turn back into those stock items (Deprecated Bone Chips, NPC Equip 20798/23357); delete
-- them from the characters database if you want them gone (item_instance.itemEntry). Mounts and
-- pets players earned stay learned. Idempotent: safe to run again.

DELETE FROM `pool_creature` WHERE `pool_entry` IN (9506001, 9506002);
DELETE FROM `pool_template` WHERE `entry` IN (9506001, 9506002);
DELETE FROM `creature` WHERE `guid` BETWEEN 9506000 AND 9506099;
DELETE FROM `gameobject` WHERE `guid` BETWEEN 9506000 AND 9506099;
DELETE FROM `gameobject_template` WHERE `entry` BETWEEN 9506000 AND 9506099;

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` IN (10, 14, 15, 23) AND `SourceGroup` = 9506000;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 1 AND `SourceEntry` = 1963;
DELETE FROM `npc_vendor` WHERE `entry` = 9506000;
DELETE FROM `itemextendedcost_dbc` WHERE `ID` BETWEEN 90430 AND 90439;
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 9506000;
DELETE FROM `reference_loot_template` WHERE `Entry` = 9506000;
DELETE FROM `creature_loot_template` WHERE `Item` IN (1963, 9506000) OR `Entry` BETWEEN 9506001 AND 9506010;
DELETE FROM `item_loot_template` WHERE `Entry` = 20798;

DELETE FROM `creature_queststarter` WHERE `quest` BETWEEN 9506000 AND 9506015;
DELETE FROM `creature_questender` WHERE `quest` BETWEEN 9506000 AND 9506015;
DELETE FROM `quest_offer_reward` WHERE `ID` BETWEEN 9506000 AND 9506015;
DELETE FROM `quest_request_items` WHERE `ID` BETWEEN 9506000 AND 9506015;
DELETE FROM `quest_template` WHERE `ID` BETWEEN 9506000 AND 9506015;

DELETE FROM `gossip_menu` WHERE `MenuID` = 9506000;
DELETE FROM `npc_text` WHERE `ID` BETWEEN 9506000 AND 9506006;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` BETWEEN 9506000 AND 9506010;
DELETE FROM `creature_text` WHERE `CreatureID` BETWEEN 9506000 AND 9506010;
DELETE FROM `creature_template_addon` WHERE `entry` BETWEEN 9506000 AND 9506010;
DELETE FROM `creature_equip_template` WHERE `CreatureID` BETWEEN 9506000 AND 9506010;
DELETE FROM `creature_template_model` WHERE `CreatureID` BETWEEN 9506000 AND 9506010;
DELETE FROM `creature_template` WHERE `entry` BETWEEN 9506000 AND 9506010;

-- Stock AzerothCore values of the repurposed items.
UPDATE `item_template` SET `class` = 7, `subclass` = 11, `name` = 'Deprecated Bone Chips', `Quality` = 1, `Flags` = 16,
  `BuyPrice` = 119, `SellPrice` = 29, `ItemLevel` = 17, `maxcount` = 0, `stackable` = 5, `bonding` = 0, `description` = ''
WHERE `entry` = 1963;
UPDATE `item_template` SET `class` = 12, `subclass` = 0, `name` = 'NPC Equip 23357', `Quality` = 0, `Flags` = 0,
  `ItemLevel` = 0, `maxcount` = 0, `stackable` = 1, `bonding` = 0, `duration` = 0, `flagsCustom` = 0, `ScriptName` = '',
  `description` = ''
WHERE `entry` = 23357;
UPDATE `item_template` SET `class` = 12, `subclass` = 0, `name` = 'NPC Equip 20798', `Quality` = 0, `Flags` = 0,
  `ItemLevel` = 0, `maxcount` = 0, `stackable` = 1, `bonding` = 0, `description` = ''
WHERE `entry` = 20798;
