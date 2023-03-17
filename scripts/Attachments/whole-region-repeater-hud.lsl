// Written by PanteraPolnocy

// SameRegionResidentSay - repeats everything you say to ALL people in region (even 3000m above), or current parcel
// Also, USE THIS SCRIPT WITH COMMON SENSE. It was meant to help disco hosts with their quizes (people beyond range etc.), NOT to throw ads through whole region.

key gOwner;
integer gActive = 0;
integer gListener = 0;
string gOriginalObjectName;
string gOwnerName;

default
{

    state_entry()
    {
        gOwner = llGetOwner();
        gOwnerName = llGetDisplayName(gOwner) + " (" + llKey2Name(gOwner) + ")";
        gOriginalObjectName = llGetObjectName();
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.25]);
        llSetText("Relaying turned off\nClick on me to turn it on", <1,1,1>, 0.25);
        llOwnerSay("Loaded: SameRegionResidentSay by Chakat Northspring (panterapolnocy.resident), 140227.");
    }

    touch_start(integer total_number)
    {

        if (gOwner != llDetectedKey(0))
        {
            return;
        }

        llListenRemove(gListener);
        if (gActive == 1)
        {
            gActive = 2;
            gListener = llListen(PUBLIC_CHANNEL, "", gOwner, "");
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0,0,1>, 1]);
            llSetText("Relaying turned on\nEverything you say is sent to all people in the current parcel", <0,0,1>, 1);
            llOwnerSay("Mode ON: Current PARCEL only");
        }
        else if (gActive == 0)
        {
            gActive = 1;
            gListener = llListen(PUBLIC_CHANNEL, "", gOwner, "");
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0,1,0>, 1]);
            llSetText("Relaying turned on\nEverything you say is sent to all people in this region", <0,1,0>, 1);
            llOwnerSay("Mode ON: Whole REGION mode");
        }
        else if (gActive == 2)
        {
            gActive = 0;
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.25]);
            llSetText("Relaying turned off\nClick on me to turn it on", <1,1,1>, 0.25);
            llOwnerSay("Mode OFF");
        }

    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == PUBLIC_CHANNEL && (gActive == 1 || gActive == 2) )
        {

            list avatarsInRegion = [];
            if (gActive == 1)
            {
                avatarsInRegion = llGetAgentList(AGENT_LIST_REGION, []);
            }
            else if (gActive == 2)
            {
                avatarsInRegion = llGetAgentList(AGENT_LIST_PARCEL, []);
            }

            integer numOfAvatars = llGetListLength(avatarsInRegion);
            if (numOfAvatars == 1)
            {
                llOwnerSay("No other avatars found within the region or parcel.");
                return;
            }

            integer index = 0;
            llSetObjectName(gOwnerName);
            while (index < numOfAvatars)
            {
                key avatarToSend = llList2Key(avatarsInRegion, index);
                if (avatarToSend != gOwner)
                {
                    llRegionSayTo(avatarToSend, 0, message);
                }
                ++index;
            }
            llSetObjectName(gOriginalObjectName);

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
