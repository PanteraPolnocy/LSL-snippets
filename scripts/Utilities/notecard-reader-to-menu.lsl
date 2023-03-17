// Written by PanteraPolnocy

string gNotecardName = "urls";
integer gChannelToSendUrls = 0;

key gNotecardQueryId;
integer gNotecardLine;

integer gScriptReady;
integer gListenHandle;
integer gDialogChannel;

list gItemsList;
list gLabelsList;

stopListener()
{
    llListenRemove(gListenHandle);
    llSetTimerEvent(0);
}
 
default
{

    on_rez(integer sp)
    {
        llResetScript();
    }

    state_entry()
    {
        if (llGetInventoryKey(gNotecardName) == NULL_KEY)
        {
            llOwnerSay("Notecard '" + gNotecardName + "' missing or unwritten.");
            return;
        }
        gDialogChannel = (integer)(llFrand(-10000000)-10000000);
        gNotecardQueryId = llGetNotecardLine(gNotecardName, 0);
    }

    dataserver(key query_id, string data)
    {
        if (query_id == gNotecardQueryId)
        {
            if (data == EOF)
            {
                gScriptReady = TRUE;
                llOwnerSay("Ready.");
            }
            else
            {
                list itemParts = llParseString2List(data, ["|"], []);
                gLabelsList += llBase64ToString(llGetSubString(llStringToBase64(llList2String(itemParts, 0)), 0, 31));
                gItemsList += llList2String(itemParts, 1);
                ++gNotecardLine;
                if (gNotecardLine > 11)
                {
                    gScriptReady = TRUE;
                    llOwnerSay("Ready, but only with first 12 items.");
                    return;
                }
                gNotecardQueryId = llGetNotecardLine(gNotecardName, gNotecardLine);
            }
        }
    }

    touch_start(integer tn)
    {

        key clickerKey = llDetectedKey(0);

        if (!gScriptReady)
        {
            llRegionSayTo(clickerKey, 0, "Script is not ready yet, please wait.");
            return;
        }
        else if (llVecDist(llDetectedPos(0), llGetPos()) > 20)
        {
            llRegionSayTo(clickerKey, 0, "You need to come closer.");
            return;
        }

        gListenHandle = llListen(gDialogChannel, "", clickerKey, "");
        llDialog(clickerKey, "Select an option", gLabelsList, gDialogChannel);
        llSetTimerEvent(60);

    }

    listen(integer channel, string name, key id, string message)
    {
        stopListener();
        integer listPos = llListFindList(gLabelsList, (list)message);
        if (listPos != -1)
        {
            llRegionSay(gChannelToSendUrls, llList2String(gItemsList, listPos));
            return;
        }
        llRegionSayTo(id, 0, "Menu option not found, try again.");
    }

    timer()
    {
        stopListener();
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            llResetScript();
        }
    }

}