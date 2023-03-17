// Written by PanteraPolnocy

float gTimerInterval = 7.7; // Experiment with this value, needs to be a bit shorter than the sound file (~ 8.0 - 8.1 s)

integer gIsPlaying;
integer gCurrentFragment;
integer gSongLength;

list gSong = [
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
];

setHoverText(string theText)
{
    llSetText(theText, <1, 1, 1>, 0.5);
}

default
{

    state_entry()
    {
        llOwnerSay("Loading...");
        llStopSound();
        setHoverText("");
        gSongLength = llGetListLength(gSong);
        llPreloadSound(llList2String(gSong, 0));
        llOwnerSay("Ready.");
    }

    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            gIsPlaying = !gIsPlaying;
            llSetSoundQueueing(TRUE);
            if (gIsPlaying)
            {
                setHoverText("Fragment 1/" + (string)gSongLength + "...");
                llOwnerSay("Playing.");
                gCurrentFragment = 0;
                llSetTimerEvent(gTimerInterval);
                llPlaySound(llList2String(gSong, 0), 1);
                llPreloadSound(llList2String(gSong, 1));
                return;
            }
            llSetTimerEvent(0);
            llStopSound();
            setHoverText("");
            llOwnerSay("Stopped.");
        }
    }

    timer()
    {

        ++gCurrentFragment;

        if (gCurrentFragment >= gSongLength) {
            gCurrentFragment = 0;
        }

        integer preloadIndex = gCurrentFragment + 1;
        if (preloadIndex >= gSongLength) {
            preloadIndex = 0;
        }

        setHoverText("Fragment " + (string)(gCurrentFragment + 1) + "/" + (string)gSongLength + "...");
        llPlaySound(llList2String(gSong, gCurrentFragment), 1);
        llPreloadSound(llList2String(gSong, preloadIndex));
        llSetTimerEvent(gTimerInterval);

    }

    on_rez(integer sp)
    {
        llResetScript();
    }

}