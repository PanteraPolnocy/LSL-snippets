// This script was made by PanteraPolnocy Resident, 5e9cbbb8-1aef-4692-bfc4-a53f8c8fcbc9
// Script template version used: 1.9

key gOwnerKey;
string gOwnerName;
integer gDialogChannel;
integer gListenHandle;

key gNotecardQueryId;
integer gNotecardLine;
string gNotecardName = "config";

string gAnimationName = "animation";

// Some handy functions, unused may be deleted

// Get a random list element
string getRandomListElement(list elements)
{
    return llList2String(llListRandomize(elements, 0), 0);
}

// Check if item is on list - change 'string' to any other data type you need
integer isOnList(list testList, string testItem)
{
    if (~llListFindList(testList, (list)testItem))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// Check if you can rezz at position
integer isRezzable(vector currentPos)
{

    integer parcelFlags = llGetParcelFlags(currentPos);
    integer passedRezzCheck;
    list details;

    if (parcelFlags & PARCEL_FLAG_ALLOW_CREATE_OBJECTS)
    {
        passedRezzCheck = 1;
    }
    else
    {
        details = llGetParcelDetails(currentPos, [PARCEL_DETAILS_OWNER, PARCEL_DETAILS_GROUP]);
    }

    if (passedRezzCheck != 1)
    {
        if (llList2Key(details, 0) == llGetOwner())
        {
            passedRezzCheck = 1;
        }
        else if ((parcelFlags & PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS) && llSameGroup(llList2Key(details, 1)) == TRUE)
        {
            passedRezzCheck = 1;
        }
    }

    if (passedRezzCheck != 1)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }

}

// Check if string is a valid vector
integer isVector(string testString)
{
    list tempList = llParseString2List(testString, [" "], ["<", ">", ","]);
    if (llGetListLength(tempList) != 7)
    {
        return FALSE;
    }
    else
    {
        if (((string)((vector)testString) == (string)((vector)((string)llListInsertList(tempList, ["-"], 5)))) == FALSE)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }
}

// Search and replace in string
string searchAndReplace(string input, string old, string new) 
{
    return llDumpList2String(llParseStringKeepNulls((input = "") + input, [old], []), new);
}

// Rotations translation
rotation vector2rot(vector calrot)
{
    return llEuler2Rot(calrot * DEG_TO_RAD); // Quron Dagger's one, after modification
}

vector rot2vector(rotation calrot)
{
    return RAD_TO_DEG * llRot2Euler(calrot);
}

// Colors translation
vector lsl2rgb(vector values)
{
    values *= 255;
    return <(integer)values.x, (integer)values.y, (integer)values.z>;
}

vector rgb2lsl(vector values)
{
    return values / 255;
}

// Long range prim moving, change LINK_THIS to LINK_ROOT if needed
longRangemoveToPos(vector position)
{
    if (position.z < 4096)
    {
        llSetRegionPos(position);
    }
    while (llList2Vector(llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POSITION]), 0) != position)
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POSITION, position]);
    }
}

// Using no_sensor() as second llSetTimerEvent()
setTimerEvent2(float time)
{
    if (time <= 0)
    {
        llSensorRemove();
    }
    else if (time < 0.5)
    {
        llOwnerSay("For performance reasons you can't set setTimerEvent2() value < than 0.5");
    }
    else
    {
        llSensorRepeat("cake is a lie", NULL_KEY, AGENT_BY_LEGACY_NAME, 0.001, 0.001, time);
    }
}

// Use llInstantMessage() only when it's really neccessary
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

// Script starts here
default
{

    state_entry()
    {

        // Populating often used variables
        gOwnerKey = llGetOwner();
        gOwnerName = llGetDisplayName(gOwnerKey) + " (" + llKey2Name(gOwnerKey) + ")";
        gDialogChannel = (integer)(llFrand(-10000000)-10000000);

        // Notecard reader here
        if (llGetInventoryKey(gNotecardName) == NULL_KEY)
        {
            llOwnerSay("Notecard '" + gNotecardName + "' missing or unwritten.");
        }
        else
        {
            gNotecardQueryId = llGetNotecardLine(gNotecardName, 0);
        }

        // Some memory management here, with mininum 20KB buffer
        // Note: if notecard reading system will be used, then this should be moved to the end of 'if (data == EOF)' section in 'dataserver' event, right before 'return;'
        integer usedMemory = llGetUsedMemory();
        if (usedMemory < 45056)
        {
            llSetMemoryLimit(usedMemory + 20480);
        }

        // Work: non-script zones. See run_time_permissions().
        // If no animation is used in script feel free to replace '(PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION)' with 'PERMISSION_TAKE_CONTROLS'
        if (llGetAttached() != 0)
        {
            llRequestPermissions(gOwnerKey, (PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION));
        }

    }

    listen(integer channel, string name, key id, string message)
    {

        // This shouldn't happen, if listener is set to a fixed channel anyway
        // Feel free to remove it, if you're using only one channel
        if (channel != gDialogChannel)
        {
            return;
        }

        llOwnerSay(message);
        llSetTimerEvent(2); // Speed up time, so llListenRemove() can be called

    }

    touch_start(integer total_number)
    {
        gListenHandle = llListen(gDialogChannel, "", gOwnerKey, "");
        llDialog(gOwnerKey, "\nMew.", ["Mew", "Purr", "Cookies"], gDialogChannel);
        llSetTimerEvent(60);
    }

    timer()
    {
        llListenRemove(gListenHandle); // Save some CPU/memory, if channel is not used for some time
        llSetTimerEvent(0);
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

    dataserver(key request_id, string data)
    {
        if (request_id == gNotecardQueryId)
        {
            if (data == EOF)
            {
                llOwnerSay("Notecard read, " + (string)gNotecardLine + " lines.");
                return;
            }
            else if (data != "")
            {
                llOwnerSay("Notecard line: " + data);
            }
            gNotecardQueryId = llGetNotecardLine(gNotecardName, ++gNotecardLine);
        }
    }

    changed(integer change)
    {
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY | CHANGED_ALLOWED_DROP))
        {
            llResetScript();
        }
        else if (change & CHANGED_LINK)
        { 
            key avatarKey = llAvatarOnLinkSitTarget(LINK_THIS);
            if (avatarKey)
            {
                llRequestPermissions(avatarKey, (PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION));
            }
        }
    }

    attach(key avatarKey)
    {
        if (avatarKey)
        {
            llRequestPermissions(avatarKey, (PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION));
        }
        else
        {
            llStopAnimation(gAnimationName);
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llStartAnimation(gAnimationName);
        }
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            // Take control for value that does nothing, in order to work in no-script sims
            llTakeControls(1024, TRUE, TRUE);
        }
    }

    no_sensor()
    {
        // If there is no sensor event in script itself, then setTimerEvent2() function becomes available
        // no_sensor() is used as a second timer(), because lightweight llSensorRepeat() query is using impossible to meet requirements
        llOwnerSay("Timer event 2");
    }

}