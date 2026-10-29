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
 * Released under the MIT License.
 */

#include "Chat.h"
#include "DatabaseEnv.h"
#include "Item.h"
#include "ItemScript.h"
#include "Mail.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

namespace
{
    constexpr uint32 ITEM_PRIMAL_EGG = 23357;
    constexpr uint32 ITEM_HATCHED_PRIMAL_EGG = 20798;
    constexpr uint32 NPC_JUZARO = 9506000;
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

void AddPrimalBonesScripts()
{
    new item_primal_egg();
}
