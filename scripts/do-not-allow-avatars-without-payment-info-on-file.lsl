// Written by PanteraPolnocy

key gRequestId;
list gAgentList;
integer gAgentListLength;

key gCurrentResident;
key gOwnerKey;

scanArea()
{
    gAgentList = llGetAgentList(AGENT_LIST_PARCEL, []);
    integer ownerIndex = llListFindList(gAgentList, [gOwnerKey]);
    if (~ownerIndex)
    {
        gAgentList = llDeleteSubList(gAgentList, ownerIndex, ownerIndex);
    }
    gAgentListLength = llGetListLength(gAgentList);
    getNextAvatarKey();
}

getNextAvatarKey()
{
    if (gAgentListLength > 0)
    {
        --gAgentListLength;
        gCurrentResident = llList2Key(gAgentList, gAgentListLength);
        gRequestId = llRequestAgentData(gCurrentResident, DATA_PAYINFO);
    }
}

default
{

    state_entry()
    {
        gOwnerKey = llGetOwner();
        scanArea();
        llSetTimerEvent(30);
    }

    timer()
    {
        scanArea();
    }

    dataserver(key queryid, string data)
    {
        if (gRequestId == queryid)
        {
            if (data == "0" && llOverMyLand(gCurrentResident))
            {
                llOwnerSay("Ejecting secondlife:///app/agent/" + (string)gCurrentResident + "/about");
                llRegionSayTo(gCurrentResident, 0, "Residents without payment info on file are not allowed in this area, goodbye.");
                llEjectFromLand(gCurrentResident);
            }
            getNextAvatarKey();
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }

}