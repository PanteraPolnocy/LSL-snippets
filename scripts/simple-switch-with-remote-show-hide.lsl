// Written by PanteraPolnocy

// Switch script

integer gCurrentState;
key gOwnerKey;
integer gChannel = 0;

default
{
    state_entry()
    {
        gOwnerKey = llGetOwner();
        llSetMemoryLimit(llGetUsedMemory() + 1024);
    }

    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == gOwnerKey)
        {
            gCurrentState = !gCurrentState;
            if (gCurrentState)
            {
                llShout(gChannel, "show");
            }
            else
            {
                llShout(gChannel, "hide");
            }
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }
}

// Light script

key gOwnerKey;
integer gChannel = 0;

default
{
    state_entry()
    {
        gOwnerKey = llGetOwner();
        llListen(gChannel, "", NULL_KEY, "");
        llSetMemoryLimit(llGetUsedMemory() + 5120);
    }

    listen(integer channel, string name, key id, string message)
    {
        if (llGetOwnerKey(id) == gOwnerKey)
        {
            if (message == "hide")
            {
                llSetLinkAlpha(LINK_SET, 0.0, ALL_SIDES);
            }
            else if (message == "show")
            {
                llSetLinkAlpha(LINK_SET, 1.0, ALL_SIDES);
            }
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }
}