// Written by PanteraPolnocy

stopListener()
{
	llSetTimerEvent(0);
	llListenRemove((integer)llLinksetDataRead("listener_handle"));
}

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	timer()
	{
		stopListener();
	}

	state_entry()
	{
		llLinksetDataReset();
		llLinksetDataWrite("owner_key", (string)llGetOwner());
		llLinksetDataWrite("listener_channel", (string)((integer)(llFrand(-10000000)-10000000)));
		llLinksetDataWrite("attachment_points", "[\"Chest\", \"Skull\", \"Left Shoulder\", \"Right Shoulder\", \"Left Hand\", \"Right Hand\", \"Left Foot\", \"Right Foot\", \"Spine\", \"Pelvis\", \"Mouth\", \"Chin\", \"Left Ear\", \"Right Ear\", \"Left Eye\", \"Right Eye\", \"Nose\", \"R Upper Arm\", \"R Lower Arm\", \"L Upper Arm\", \"L Lower Arm\", \"Right Hip\", \"R Upper Leg\", \"R Lower Leg\", \"Left Hip\", \"L Upper Leg\", \"L Lower Leg\", \"Stomach\", \"Left Pec\", \"Right Pec\", \"HUD Center 2\", \"HUD Top Right\", \"HUD Top\", \"HUD Top Left\", \"HUD Center\", \"HUD Bottom Left\", \"HUD Bottom\", \"HUD Bottom Right\", \"Neck\", \"Avatar Center\", \"Left Ring Finger\", \"Right Ring Finger\", \"Tail Base\", \"Tail Tip\", \"Left Wing\", \"Right Wing\", \"Jaw\", \"Alt Left Ear\", \"Alt Right Ear\", \"Alt Left Eye\", \"Alt Right Eye\", \"Tongue\", \"Groin\", \"Left Hind Foot\", \"Right Hind Foot\"]");
	}

	touch_start(integer total_number)
	{
		key ownerKey = (key)llLinksetDataRead("owner_key");
		if (llDetectedKey(0) == ownerKey)
		{
			integer listenChannel = (integer)llLinksetDataRead("listener_channel");
			llLinksetDataWrite("listener_handle", (string)llListen(listenChannel, "", ownerKey, "")); 
			llTextBox(ownerKey, "\nPlease paste avatar key (UUID) you'd like to scan. Needs to be in the same region as you.", listenChannel);
			llSetTimerEvent(60);
		}
	}

	listen(integer channel, string name, key id, string target)
	{
		stopListener();
		if ((key)target)
		{

			string items = llList2Json(JSON_ARRAY, llGetAttachedList((key)target));
			string currentItem = llJsonValueType(items, []);
			if (currentItem != JSON_INVALID)
			{
				llOwnerSay("==== Starting attachment scan for secondlife:///app/agent/" + target + "/about");
				string attachmentPoints = llLinksetDataRead("attachment_points");
				integer i;
				integer wornOBJECTRUNNINGSCRIPTCOUNT;
				integer wornOBJECTTOTALSCRIPTCOUNT;
				integer wornOBJECTSCRIPTMEMORY;
				float wornOBJECTSCRIPTTIME;
				while ((currentItem = llJsonGetValue(items, [i])) != JSON_INVALID)
				{

					string attachment = llList2Json(JSON_ARRAY, llGetObjectDetails((key)currentItem, [
						OBJECT_NAME,
						OBJECT_CREATOR,
						OBJECT_GROUP,
						OBJECT_ATTACHED_POINT,
						OBJECT_RUNNING_SCRIPT_COUNT,
						OBJECT_TOTAL_SCRIPT_COUNT,
						OBJECT_SCRIPT_MEMORY,
						OBJECT_SCRIPT_TIME
					]));

					string activeGroup = llJsonGetValue(attachment, [2]);
					if ((key)activeGroup == NULL_KEY)
					{
						activeGroup = "";
					}
					else
					{
						activeGroup = "[Group: secondlife:///app/group/" + activeGroup + "/about] ";
					}

					integer itemOBJECTRUNNINGSCRIPTCOUNT = (integer)llJsonGetValue(attachment, [4]);
					integer itemOBJECTTOTALSCRIPTCOUNT = (integer)llJsonGetValue(attachment, [5]);
					integer itemOBJECTSCRIPTMEMORY = (integer)llJsonGetValue(attachment, [6]);
					float itemOBJECTSCRIPTTIME = (float)llJsonGetValue(attachment, [7]);

					llOwnerSay(
						"[" + llJsonGetValue(attachment, [0]) + "] " +
						"[" + llJsonGetValue(attachmentPoints, [(integer)llJsonGetValue(attachment, [3]) - 1]) + "] " + 
						"[Creator: secondlife:///app/agent/" + llJsonGetValue(attachment, [1]) + "/about] " +
						activeGroup +
						"[Scripts: " +
							(string)itemOBJECTRUNNINGSCRIPTCOUNT + "/" +
							(string)itemOBJECTTOTALSCRIPTCOUNT + ", " +
							(string)(itemOBJECTSCRIPTMEMORY / 1024) + " KB, " +
							(string)(itemOBJECTSCRIPTTIME * 1000.0) + " ms]"
					);

					wornOBJECTRUNNINGSCRIPTCOUNT += itemOBJECTRUNNINGSCRIPTCOUNT;
					wornOBJECTTOTALSCRIPTCOUNT += itemOBJECTTOTALSCRIPTCOUNT;
					wornOBJECTSCRIPTMEMORY += itemOBJECTSCRIPTMEMORY;
					wornOBJECTSCRIPTTIME += itemOBJECTSCRIPTTIME;
					++i;

				}

				items = "";
				currentItem = "";
				attachmentPoints = "";

				llOwnerSay("==== Detected: " + (string)i + " visible attachments worn, excluding HUDs.");

				string hudsProbe = llList2Json(JSON_ARRAY, llGetObjectDetails((key)target, [
					OBJECT_RUNNING_SCRIPT_COUNT,
					OBJECT_TOTAL_SCRIPT_COUNT,
					OBJECT_SCRIPT_MEMORY,
					OBJECT_SCRIPT_TIME
				]));

				llOwnerSay("==== Combined HUDs resource usage [Scripts: " +
					(string)((integer)llJsonGetValue(hudsProbe, [0]) - wornOBJECTRUNNINGSCRIPTCOUNT) + "/" +
					(string)((integer)llJsonGetValue(hudsProbe, [1]) - wornOBJECTTOTALSCRIPTCOUNT) + ", " +
					(string)(((integer)llJsonGetValue(hudsProbe, [2]) - wornOBJECTSCRIPTMEMORY) / 1024) + " KB, " +
					(string)(((float)llJsonGetValue(hudsProbe, [3]) - wornOBJECTSCRIPTTIME) * 1000.0) + " ms]");

				llOwnerSay("==== Total resource usage [Scripts: " +
					(string)((integer)llJsonGetValue(hudsProbe, [0])) + "/" +
					(string)((integer)llJsonGetValue(hudsProbe, [1])) + ", " +
					(string)(((integer)llJsonGetValue(hudsProbe, [2])) / 1024) + " KB, " +
					(string)(((float)llJsonGetValue(hudsProbe, [3])) * 1000.0) + " ms]");

				llOwnerSay("==== Scan finished.");

			}
		}
		else
		{
			llOwnerSay("Avatar key does not look correct. Please re-check.");
		}
	}

}
