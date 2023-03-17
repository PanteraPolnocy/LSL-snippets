// Written by PanteraPolnocy

integer gListenHandle;
integer gDialogChannel;

stopListener()
{
    llListenRemove(gListenHandle);
    llSetTimerEvent(0);
}

default
{

    state_entry()
    {
        gDialogChannel = (integer)(llFrand(-1000000000)-1000000000);
        llSetMemoryLimit(llGetUsedMemory() + 5120);
    }

    listen(integer channel, string name, key id, string message)
    {
        llSetParcelMusicURL(llStringTrim(message, STRING_TRIM));
        stopListener();
    }

    touch_start(integer total_number)
    {
        key toucherKey = llDetectedKey(0);
        if (toucherKey == llGetOwner())
        {
            gListenHandle = llListen(gDialogChannel, "", toucherKey, "");
            llTextBox(toucherKey, "\nMew.\nDefault stream: http://relay1.slayradio.org:8000", gDialogChannel);
            llSetTimerEvent(60);
        }
    }

    timer()
    {
        stopListener();
    }

}