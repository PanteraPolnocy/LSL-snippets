// Written by PanteraPolnocy

string gSavedData;

sendPrivMessage(key targetAvatar, string targetMsg)
{
    targetMsg = "\n--" + targetMsg;
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

string returnFlagTest(string flagLabel, integer flagToTest, integer parcelFlags)
{
    string returnValue;
    returnValue += "\n[" + flagLabel + "]";
    if (!(parcelFlags & flagToTest)) {
        returnValue += "N";
    } else {
        returnValue += "Y";
    }
    return returnValue;
}

string returnParcelInfo()
{
    vector currentPos = llGetPos();

    list parcelDetails = llGetParcelDetails(currentPos, [PARCEL_DETAILS_NAME, PARCEL_DETAILS_DESC, PARCEL_DETAILS_OWNER, PARCEL_DETAILS_GROUP, PARCEL_DETAILS_AREA, PARCEL_DETAILS_ID, PARCEL_DETAILS_SEE_AVATARS]);
    string returnValue = "\n[Name]" + llList2String(parcelDetails, 0) + "\n[Desc]" + llList2String(parcelDetails, 1) + "\n[Owner]" + llList2String(parcelDetails, 2) + "\n[Group]" + llList2String(parcelDetails, 3) + "\n[Area]" + llList2String(parcelDetails, 4) + "\n[ID]" + llList2String(parcelDetails, 5) + "\n[SeeAvatars]" + llList2String(parcelDetails, 6);

    integer parcelFlags = llGetParcelFlags(currentPos);
    returnValue += returnFlagTest("AllowFly", PARCEL_FLAG_ALLOW_FLY, parcelFlags);
    returnValue += returnFlagTest("AllowScripts", PARCEL_FLAG_ALLOW_SCRIPTS, parcelFlags);
    returnValue += returnFlagTest("AllowLM", PARCEL_FLAG_ALLOW_LANDMARK, parcelFlags);
    returnValue += returnFlagTest("AllowTerraform", PARCEL_FLAG_ALLOW_TERRAFORM, parcelFlags);
    returnValue += returnFlagTest("AllowDmg", PARCEL_FLAG_ALLOW_DAMAGE, parcelFlags);
    returnValue += returnFlagTest("AllowCreateObjs", PARCEL_FLAG_ALLOW_CREATE_OBJECTS, parcelFlags);
    returnValue += returnFlagTest("UseAccessGroup", PARCEL_FLAG_USE_ACCESS_GROUP, parcelFlags);
    returnValue += returnFlagTest("UseAccessList", PARCEL_FLAG_USE_ACCESS_LIST, parcelFlags);
    returnValue += returnFlagTest("UseBanList", PARCEL_FLAG_USE_BAN_LIST, parcelFlags);
    returnValue += returnFlagTest("UseLandPassList", PARCEL_FLAG_USE_LAND_PASS_LIST, parcelFlags);
    returnValue += returnFlagTest("LocalSoundOnly", PARCEL_FLAG_LOCAL_SOUND_ONLY, parcelFlags);
    returnValue += returnFlagTest("RestrictPushObjs", PARCEL_FLAG_RESTRICT_PUSHOBJECT, parcelFlags);
    returnValue += returnFlagTest("AllowGroupScripts", PARCEL_FLAG_ALLOW_GROUP_SCRIPTS, parcelFlags);
    returnValue += returnFlagTest("AllowCreateGroupObjs", PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS, parcelFlags);
    returnValue += returnFlagTest("AllowAllObjsEntry", PARCEL_FLAG_ALLOW_ALL_OBJECT_ENTRY, parcelFlags);
    returnValue += returnFlagTest("AllowGroupObjsEntry", PARCEL_FLAG_ALLOW_GROUP_OBJECT_ENTRY, parcelFlags);

    return returnValue;
}

default
{

    state_entry()
    {
        gSavedData = returnParcelInfo();
        llSetTimerEvent(60);
    }

    timer()
    {
        string parcelInfo = returnParcelInfo();
        if (gSavedData != parcelInfo)
        {
            vector pos = llGetPos();
            key ownerKey = llGetOwner();
            sendPrivMessage(ownerKey, "WARNING, PARCEL DATA HAS CHANGED FOR THE LOCATION BELOW:\n http://maps.secondlife.com/secondlife/" + llEscapeURL(llGetRegionName()) + "/" + (string)llRound(pos.x) + "/" + (string)llRound(pos.y) + "/" + (string)llRound(pos.z));
            sendPrivMessage(ownerKey, "PREVIOUS DATA:" + gSavedData);
            sendPrivMessage(ownerKey, "CURRENT DATA:" + parcelInfo);
            gSavedData = parcelInfo;
            parcelInfo = "";

            list avatarsInParcel = llGetAgentList(AGENT_LIST_PARCEL, []);
            integer numOfAvatars = llGetListLength(avatarsInParcel);

            if (!numOfAvatars)
            {
                sendPrivMessage(ownerKey, "NO AVATARS FOUND WITHIN THE PARCEL");
                llOwnerSay("!");
            }
            else
            {
                integer index;
                while (index < numOfAvatars)
                {
                    parcelInfo += "\n" + llKey2Name(llList2Key(avatarsInParcel, index));
                    ++index;
                }
                sendPrivMessage(ownerKey, "AVATARS ON PARCEL:" + parcelInfo);
            }

        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

}
