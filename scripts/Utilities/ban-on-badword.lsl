// Written by PanteraPolnocy

list gPeopleToSendImToInAdditionToOwner = [
    "xxxxxxxxxxxxxxxxxxxxxxxxxxxx", // Avatar #1
    "zzzzzzzzzzzzzzzzzzzzzzzzzzzz" // Avatar #2
];

list gBadStringsList = [
    "voldemort",
    "fight club"
];

// ---------------------------------------

integer gLengthBadStringsList;
integer gLengthPeopleToSendImToInAdditionToOwner;
list gBannedPeople;

sendPrivMessage(key targetAvatar, string targetMsg)
{
    if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
    {
        // User in region, use a function without delay and better visibility in chat
        llRegionSayTo(targetAvatar, 0, targetMsg);
    }
    else
    {
        // User not in region, use long-range function with 2 seconds delay
        llInstantMessage(targetAvatar, targetMsg);
    }
}

default
{

    on_rez(integer sp)
    {
        llResetScript();
    }

    state_entry()
    {
        gPeopleToSendImToInAdditionToOwner += (string)llGetOwner();
        gLengthBadStringsList = llGetListLength(gBadStringsList);
        gLengthPeopleToSendImToInAdditionToOwner = llGetListLength(gPeopleToSendImToInAdditionToOwner);
        llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
    }

    touch_start(integer sp)
    {
        key toucherKey = llDetectedKey(0);
        if (llListFindList(gPeopleToSendImToInAdditionToOwner, (list)((string)toucherKey)) == -1)
        {
            sendPrivMessage(toucherKey, "Blep!");
            return;
        }
        sendPrivMessage(toucherKey, "Avatar names estate banned by this tool:");
        sendPrivMessage(toucherKey, llDumpList2String(gBannedPeople, ", "));
    }

    listen(integer channel, string name, key id, string message)
    {
        // Talking through prim? Too bad, I'll get your true UUID anyway
        id = llGetOwnerKey(id);

        message = llToLower(message);
        string avName = llKey2Name(id);

        integer i = 0;
        while(i < gLengthBadStringsList)
        {
            if  (llSubStringIndex(message, llList2String(gBadStringsList, i)) != -1)
            {

                // No matter what, you can't ban yourself or people from the list
                if (~llListFindList(gPeopleToSendImToInAdditionToOwner, (list)((string)id)))
                {
                    sendPrivMessage(id, "Mind your words!");
                    jump endloop;
                }

                if (llOverMyLand(id))
                {
                    llEjectFromLand(id); // Get out!
                    llAddToLandBanList(id, 48.0); // Parcel ban for 48 hours!
                }

                i = 0;

                // Permanent estate ban! Never enough bans!
                if (llManageEstateAccess(ESTATE_ACCESS_BANNED_AGENT_ADD, id))
                {
                    if (llListFindList(gBannedPeople, (list)avName) == -1)
                    {
                        gBannedPeople += avName;
                    }
                    while(i < gLengthPeopleToSendImToInAdditionToOwner)
                    {
                        sendPrivMessage(llList2Key(gPeopleToSendImToInAdditionToOwner, i), "=== ADDING " + avName + " (" + (string)id + ") TO ESTATE BANLIST.");
                        ++i;
                    }
                }
                else
                {
                    while(i < gLengthPeopleToSendImToInAdditionToOwner)
                    {
                        sendPrivMessage(llList2Key(gPeopleToSendImToInAdditionToOwner, i), "=== TRIED TO ADD " + avName + " (" + (string)id + ") TO ESTATE BANLIST, BUT FAILED.");
                        ++i;
                    }
                }

                jump endloop;

            }
            ++i;
        }

        @endloop;
    }

}