// Written by PanteraPolnocy

integer gLimit = 4096;

default
{

    state_entry()
    {
        llSetTimerEvent(0.6);
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

    timer()
    {
        vector currentPos = llGetPos();
        key ownerKey = llGetOwner();
        list avatars = llGetAgentList(AGENT_LIST_REGION, []);
        integer avatarsCount = llGetListLength(avatars);
        if (avatarsCount > 0)
        {

            integer i;
            list message = [];
            while (i < avatarsCount)
            {
                key avatarKey = llList2Key(avatars, i);
                if (avatarKey != NULL_KEY && avatarKey != ownerKey && llVecDist(currentPos, llList2Vector(llGetObjectDetails(avatarKey, [OBJECT_POS]), 0)) <= gLimit)﻿
                {
                    message = message + llKey2Name(avatarKey);
                }
                ++i;
            }

            integer avatarsCountToReport = llGetListLength(message);
            if (avatarsCountToReport > 0)
            {
                llMessageLinked(LINK_SET, 2, "open", "");
                llOwnerSay((string)avatarsCountToReport + " avatar(s): " + llDumpList2String(message, ", "));
            }

        }
    }


}