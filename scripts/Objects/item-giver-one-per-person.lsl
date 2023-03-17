// Written by PanteraPolnocy

list gUsersWhoAlreadyTookItem = [];

default
{

    touch_start(integer total_number)
    {

        key target = llDetectedKey(0);
        string targetName = llKey2Name(target);
        key owner = llGetOwner();
        string itemName = llList2String(llGetPrimitiveParams([PRIM_DESC]), 0);

        if (~llListFindList(gUsersWhoAlreadyTookItem, (list)targetName))
        {
            llRegionSayTo(target, 0, "It seems that you have already received " + itemName + ". Check the 'Objects' folder in your Inventory.");
        }
        else
        {
            if (llGetInventoryNumber(INVENTORY_OBJECT) > 0)
            {
                gUsersWhoAlreadyTookItem = [targetName] + gUsersWhoAlreadyTookItem;
                llRegionSayTo(target, 0, "Enjoy your " + itemName + ", " + llGetDisplayName(target) + "! Check the 'Objects' folder in your Inventory.");
                llGiveInventory(target, llGetInventoryName(INVENTORY_OBJECT, 0));
            }
            else
            {
                llRegionSayTo(target, 0, "Sorry, nothing to give at the moment. Please poke secondlife:///app/agent/" + (string)owner + "/about .");
            }
        }

        if (target == owner)
        {
            integer itemListLength = llGetListLength(gUsersWhoAlreadyTookItem);
            llOwnerSay("=== Owner-only: People who took " + itemName + ": " + (string)itemListLength);
            integer i = 0;
            while (itemListLength > i)
            {
                llOwnerSay("== " + llList2String(gUsersWhoAlreadyTookItem, i));
                ++i;
            }
            llOwnerSay("=== If you want to reset the list - reset the script itself.");
        }

    }

}
