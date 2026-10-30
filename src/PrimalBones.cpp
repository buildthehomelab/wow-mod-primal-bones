/*
 * mod-primal-bones: the Primal Egg hatching.
 *
 * Everything else in the module is data (data/sql/db-world). What data can't do is turn one
 * item into another after a while. The Primal Egg (item 23357) has a three day duration that
 * keeps ticking while its owner is offline (flagsCustom 1). When it runs out the core destroys
 * the egg and calls this script first, which gives the owner a Hatched Primal Egg (item 20798)
 * in its place. That one opens like a container; what is inside is its item_loot_template.
 *
 * The core calls the hook while the expired egg still takes up its bag slot, so a player whose
 * bags are otherwise full gets the hatched egg by mail instead of losing it.
 *
 * Every hatched egg is a Red, Black or Green Primal Raptor, and one its owner doesn't know yet:
 * the loot group's conditions can't steer that, the core rolls a group before it checks them. So
 * when the egg's loot is rolled, a known colour's chance goes to 0 and the others share 100%. An
 * owner who knows all three rolls none of them and gets the group's equal-chance entry, boss
 * coins.
 *
 * Released under the MIT License.
 */

#include "Chat.h"
#include "DatabaseEnv.h"
#include "GlobalScript.h"
#include "Item.h"
#include "ItemScript.h"
#include "LootMgr.h"
#include "Mail.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

namespace
{
    constexpr uint32 ITEM_PRIMAL_EGG = 23357;
    constexpr uint32 ITEM_HATCHED_PRIMAL_EGG = 20798;
    constexpr uint32 NPC_JUZARO = 9506000;

    // Red, Black and Green Primal Raptor: each item teaches the mount spell with its own id.
    constexpr uint32 EGG_RAPTORS[] = { 400538, 400539, 400540 };

    bool IsEggRaptor(uint32 itemId)
    {
        for (uint32 raptor : EGG_RAPTORS)
            if (raptor == itemId)
                return true;
        return false;
    }
}

class item_primal_egg : public ItemScript
{
public:
    item_primal_egg() : ItemScript("item_primal_egg") { }

    bool OnExpire(Player* player, ItemTemplate const* proto) override
    {
        if (!player || !proto || proto->ItemId != ITEM_PRIMAL_EGG)
            return false;

        if (player->AddItem(ITEM_HATCHED_PRIMAL_EGG, 1))
            return true;

        Item* item = Item::CreateItem(ITEM_HATCHED_PRIMAL_EGG, 1, player);
        if (!item)
            return false;

        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        item->SaveToDB(trans);
        MailDraft("A hatched egg", "Your Primal Egg hatched while your bags were full. Ju'zaro kept it warm for you.")
            .AddItem(item)
            .SendMailTo(trans, MailReceiver(player), MailSender(MAIL_CREATURE, NPC_JUZARO));
        CharacterDatabase.CommitTransaction(trans);

        if (player->GetSession())
            ChatHandler(player->GetSession()).SendSysMessage("Your Primal Egg hatched, but your bags are full: it is in your mail.");
        return true;
    }
};

class PrimalEggLootScript : public GlobalScript
{
public:
    PrimalEggLootScript() : GlobalScript("PrimalEggLootScript", { GLOBALHOOK_ON_ITEM_ROLL }) { }

    bool OnItemRoll(Player const* player, LootStoreItem const* lootStoreItem, float& chance, Loot& loot, LootStore const& store) override
    {
        if (!player || &store != &LootTemplates_Item || !IsEggRaptor(lootStoreItem->itemid))
            return true;

        Item* egg = player->GetItemByGuid(loot.containerGUID);
        if (!egg || egg->GetEntry() != ITEM_HATCHED_PRIMAL_EGG)
            return true;

        if (player->HasSpell(lootStoreItem->itemid))
        {
            chance = 0.0f;
            return true;
        }

        uint32 unknown = 0;
        for (uint32 raptor : EGG_RAPTORS)
            if (!player->HasSpell(raptor))
                ++unknown;

        chance = 100.0f / unknown;
        return true;
    }
};

void AddPrimalBonesScripts()
{
    new item_primal_egg();
    new PrimalEggLootScript();
}
