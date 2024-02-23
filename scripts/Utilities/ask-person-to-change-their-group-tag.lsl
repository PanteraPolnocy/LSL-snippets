// Group tag checker with whitelist, by Panterapolnocy
// Feb 2024

// Everything needs to be lowercase in this list
list gForbiddenWordsInGroupTags = [
    "helper",
    "owner",
    "manager",
    "staff",
    "support"
];

list gGroupTagsWhitelist = [
    "FS Gateway Helper",
    "Firestorm Support",
    "Firestorm Developer",
    "Firestorm Instructor",
    "FS Gateway",
    "FS Team"
];

integer gForbiddenWordsLength;

default
{

    on_rez(integer so)
    {
        llResetScript();
    }

    state_entry()
    {
        gForbiddenWordsLength = llGetListLength(gForbiddenWordsInGroupTags);
        llSetTimerEvent(300);
    }

    timer()
    {

        list avatarsInRegion = llGetAgentList(AGENT_LIST_REGION, []);
        integer numOfAvatars = llGetListLength(avatarsInRegion);
        integer index;
        integer wordIndex;

        while (index < numOfAvatars)
        {
            key targetAvatar = llList2Key(avatarsInRegion, index);
            string activeGroupTag = llList2String(llGetObjectDetails(targetAvatar, [OBJECT_GROUP_TAG]), 0);
            if (activeGroupTag != "")
            {
                string activeGroupTagLowercase = llToLower(activeGroupTag);
                wordIndex = 0;
                while (wordIndex < gForbiddenWordsLength)
                {
                    string wordToCheck = llList2String(gForbiddenWordsInGroupTags, wordIndex);
                    if (~llSubStringIndex(activeGroupTagLowercase, wordToCheck) && llListFindList(gGroupTagsWhitelist, [activeGroupTag]) == -1)
                    {
                        llRegionSayTo(targetAvatar, 0, "Hey there, secondlife:///app/agent/" + (string)targetAvatar + "/about! I noticed that your current group tag, \"" + activeGroupTag + "\", might be causing some confusion in this area.\n\nHaving group tags like that could potentially perplex other visitors, so it's best to switch to a different one. No worries! You can easily do this by opening your Friends List, navigating to the Groups tab, and activating a new group. Thank you for your understanding and cooperation, have a nice day!");
                    }
                    ++wordIndex;
                }
            }
            ++index;
        }

    }

}
