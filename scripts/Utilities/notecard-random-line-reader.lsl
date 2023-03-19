// Written by PanteraPolnocy

integer gLinesAmount;
key gLineRequestID;
key gNotecardQueryId;
string gNotecardName;

default
{

    on_rez(integer sp)
    {
        llResetScript();
    }

    state_entry()
    {
        if (!llGetInventoryNumber(INVENTORY_NOTECARD))
        {
            llOwnerSay("There is no notecard inside me.");
            return;
        }
        gNotecardName = llGetInventoryName(INVENTORY_NOTECARD, 0);
        llOwnerSay("Registering notecard '" + gNotecardName + "' as the source for quotes.");
        gLineRequestID = llGetNumberOfNotecardLines(gNotecardName);
    }

    dataserver(key requested, string data)
    {
        if (requested == gNotecardQueryId)
        {
            llSay(0, data);
        }
        else if (requested == gLineRequestID)
        {
            gLinesAmount = (integer)data;
            llOwnerSay("Ready. Lines amount: " + data);
            llSetMemoryLimit(llGetUsedMemory() + 10240);
        }
    }

    touch_start(integer total_number)
    {
        if (!gLinesAmount)
        {
            llOwnerSay("There are no lines to read from.");
            return;
        }
        gNotecardQueryId = llGetNotecardLine(gNotecardName, llRound(llFrand(gLinesAmount - 1)));
    }

    changed(integer change)
    {
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY | CHANGED_ALLOWED_DROP))
        {
            llResetScript();
        }
    }

}