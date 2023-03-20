// Written by PanteraPolnocy

float gRegionFPSMessageTrigger = 10.0; // IM owners when FPS is lower than that
string gLowFPSMessage = "WARNING. Region FPS is low."; // Low FPS message
string gRegionRestartMessage = "Detected a region simulator reset."; // Region restart message

// Keys notecard
string gNotecardName = "keys";
key gNotecardQueryId;
integer gNotecardLine;

list gAvatars = [
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", // Avatar key #1
	"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" // Avatar key #2
];

// Filled dynamically by script
integer gAvatarListLength;
string gPositionString;

optimizeMemory()
{
	integer usedMemory = llGetUsedMemory();
	if (usedMemory < 45056)
	{
		llSetMemoryLimit(usedMemory + 20480);
	}
}

sendMessageToAll(string targetMsg)
{
	integer i = 0;
	while (i < gAvatarListLength)
	{
		key tempAvatar = llList2Key(gAvatars, i);
		if (llGetAgentSize(tempAvatar) != ZERO_VECTOR)
		{
			// User in region, use a function without delay and better visibility in chat
			llRegionSayTo(tempAvatar, 0, targetMsg);
		}
		else
		{
			// User not in region, use long-range function with 2 seconds delay
			llInstantMessage(tempAvatar, targetMsg);
		}
		++i;
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

		vector currentPos = llGetPos();
		gPositionString = "[" + llList2String(llGetParcelDetails(currentPos, [PARCEL_DETAILS_NAME]), 0) + "] [ http://maps.secondlife.com/secondlife/" + llEscapeURL(llGetRegionName()) + "/" + (string)llRound(currentPos.x) + "/" + (string)llRound(currentPos.y) + "/" + (string)llRound(currentPos.z) + " ]: ";
		llSetTimerEvent(60);
		llOwnerSay("Working.");

		// Notecard reader here
		if (llGetInventoryKey(gNotecardName) == NULL_KEY)
		{
			gAvatarListLength = llGetListLength(gAvatars);
			optimizeMemory();
		}
		else
		{
			gNotecardQueryId = llGetNotecardLine(gNotecardName, 0);
		}

	}

	timer()
	{
		if (llGetRegionFPS() < gRegionFPSMessageTrigger)
		{
			sendMessageToAll(gPositionString + gLowFPSMessage);
		}
	}

	dataserver(key request_id, string data)
	{
		if (request_id == gNotecardQueryId)
		{
			if (data == EOF)
			{
				llOwnerSay("Notecard read, " + (string)gNotecardLine + " lines.");
				gAvatarListLength = llGetListLength(gAvatars);
				optimizeMemory();
				return;
			}
			else if (data != "")
			{
				if ((key)data)
				{
					gAvatars = gAvatars + llStringTrim(data, STRING_TRIM);
				}
			}
			gNotecardQueryId = llGetNotecardLine(gNotecardName, ++gNotecardLine);
		}
	}

	changed (integer vBitChanges)
	{
		if (vBitChanges & (CHANGED_OWNER | CHANGED_INVENTORY | CHANGED_ALLOWED_DROP | CHANGED_REGION))
		{
			llResetScript();
		}
		else if (CHANGED_REGION_START & vBitChanges)
		{
			sendMessageToAll(gPositionString + gRegionRestartMessage);
		}
	}

}
