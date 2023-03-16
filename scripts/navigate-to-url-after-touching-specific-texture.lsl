// Written by PanteraPolnocy

// Format: Texture UUID, Link URL
list gData = [
    "f2f807ce-c5f9-2156-eb03-f36a3c976a83", "https://www.google.com",
    "5a0538f5-23c7-b76c-7115-905cb4f8beb2", "https://www.duckduckgo.com",
    "10522cbd-8d18-3ba0-0043-782018b086b1", "https://www.bing.com"
];

default
{
    state_entry()
    {
        llOwnerSay("Touch me to go to a search engine!");
        // Optimization under Mono. Delete this line if you run into problems, or don't know what it does.
        llSetMemoryLimit(llGetUsedMemory() + 5120);
    }

    touch_start(integer total_number)
    {
        key toucherKey = llDetectedKey(0);
        string touchedTexture = llGetTexture(llDetectedTouchFace(0));
        integer indexPosition = llListFindList(gData, (list)touchedTexture);
        if (~indexPosition)
        {
            // Get the URL from data list, by texture uuid position with added 1
            string url = llList2String(gData, indexPosition + 1);
            // Send the URL to whoever touched me
            llRegionSayTo(toucherKey, 0, "Sending you to " + url);
            llLoadURL(toucherKey, "Navigate to " + url, url);
        }
        else
        {
            llRegionSayTo(toucherKey, 0, "I don't know what to do with that face!");
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }
}