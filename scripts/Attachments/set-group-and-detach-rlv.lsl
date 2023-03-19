// Written by PanteraPolnocy

string gGroupName = " Group name";
integer gListenHandle;

detachMe()
{
    llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
}

default
{

    state_entry()
    {
        llOwnerSay("@setgroup:" + gGroupName + "=force");
        llSleep(5);
        gListenHandle = llListen(7676,"", llGetOwner(), "");
        llOwnerSay("@getgroup=7676");
        llSetTimerEvent(60);
    }

    on_rez(integer start)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {
        llSetTimerEvent(0);
        llOwnerSay("Group set to: " + message);
        llListenRemove(gListenHandle);
        detachMe();
    }

    timer()
    {
        llListenRemove(gListenHandle);
        llOwnerSay("Group set failed (no response from external server). Detaching...");
        llSetTimerEvent(0);
        detachMe();
    }

    run_time_permissions(integer i)
    {
        if (i & PERMISSION_ATTACH)
        {
            llDetachFromAvatar();
        }
    }

}