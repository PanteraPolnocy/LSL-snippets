// Written by PanteraPolnocy

string gFolderName = "Cool folder name";

list gInv;
integer gInvLength;

userSay(key userKey, string userMessage)
{
    if (llGetAgentSize(userKey) != ZERO_VECTOR)
    {
        // User in region, use a function without delay and better visibility in chat
        llRegionSayTo(userKey, 0, userMessage);
    }
    else
    {
        // User not in region, use long-range function with 2 seconds delay
        llInstantMessage(userKey, userMessage);
    }
}

default
{

    state_entry()
    {

        gInv = [];
        integer i = 0;
        integer max = llGetInventoryNumber(INVENTORY_ALL);
        string thisScriptName = llGetScriptName();
        for (i=0; i<max; ++i)
        {
            string currentInventoryName = llGetInventoryName(INVENTORY_ALL, i);
            if (thisScriptName != currentInventoryName)
            {
                gInv += [currentInventoryName];
            }
        }
        gInvLength = llGetListLength(gInv);

        integer usedMemory = llGetUsedMemory();
        if (usedMemory < 45056)
        {
            llSetMemoryLimit(usedMemory + 20480);
        }

        llAllowInventoryDrop(FALSE);

    }

    changed(integer change)
    {
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY | CHANGED_ALLOWED_DROP | CHANGED_REGION_START))
        {
            llResetScript();
        }
    }

    touch_start(integer total_number)
    {
        key userClicked = llDetectedKey(0);
        if (gInvLength > 0)
        {
            userSay(userClicked, "=== Please check the new folder named '-- " + gFolderName + " --' in your inventory root, that have been sent to you. ===");
            llGiveInventoryList(userClicked, "-- " + gFolderName + " --", gInv);
        }
        else
        {
            userSay(userClicked, "Sorry, nothing to give at the moment.");
        }
    }

}