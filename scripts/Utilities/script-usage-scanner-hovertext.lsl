// Written by PanteraPolnocy for Firestorm team

integer gAvatarsLimitInHoverText = 6;
integer gRefreshRateInSeconds = 10;

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		llSetText("Script usage detector is starting up...\n(refreshing each " + (string)gRefreshRateInSeconds + " seconds)", <1, 1, 1>, 1.0);
		llSetTimerEvent(gRefreshRateInSeconds);
	}

	timer()
	{

		list avatarsInRegion = llGetAgentList(AGENT_LIST_REGION, []);
		integer numOfAvatars = llGetListLength(avatarsInRegion);
		string setTextValue;

		// if no avatars, abort avatar listing
		if (!numOfAvatars)
		{
			setTextValue = "No avatars in region";
		}
		else
		{

			vector currentPos = llGetPos();
			integer index;

			// --- SORTING

			key thisAvKey;
			list tempKeys;

			while (index < numOfAvatars)
			{
				thisAvKey = llList2Key(avatarsInRegion, index);
				if (llGetOwner() != thisAvKey)
				{
					list avDetails = llGetObjectDetails(thisAvKey, [
						OBJECT_POS,
						OBJECT_NAME,
						OBJECT_RUNNING_SCRIPT_COUNT,
						OBJECT_TOTAL_SCRIPT_COUNT,
						OBJECT_SCRIPT_MEMORY,
						OBJECT_SCRIPT_TIME
					]);
					string avName = llList2String(avDetails, 1);
					tempKeys = tempKeys + [
						(string)(llList2Float(avDetails, 5) * 1000.0),
						thisAvKey,
						llGetSubString(avName, 0, (llSubStringIndex(avName, " ") - 1)),
						(string)llList2Integer(avDetails, 2),
						(string)llList2Integer(avDetails, 3),
						(string)(llList2Integer(avDetails, 4) / 1024),
						(string)((integer)llRound(llVecDist(currentPos, llList2Vector(avDetails, 0))))
					];
				}
				++index;
			}

			avatarsInRegion = llListSort(tempKeys, 7, FALSE);
			thisAvKey = NULL_KEY;
			tempKeys = [];
			numOfAvatars = llGetListLength(avatarsInRegion);
			index = 0;

			while (index < numOfAvatars && index <= ((gAvatarsLimitInHoverText - 1) * 7))
			{
				setTextValue = setTextValue +
					llList2String(avatarsInRegion, index + 2) + " " +
					llList2String(avatarsInRegion, index + 6) + "m " +
					llList2String(avatarsInRegion, index + 3) + "/" + llList2String(avatarsInRegion, index + 4) + " " +
					llList2String(avatarsInRegion, index + 5) + "KB " +
					llGetSubString(llList2String(avatarsInRegion, index), 0, 3) + "ms" +
				"\n";
				index = index + 7;
			}

		}

		llSetText(setTextValue, <1, 1, 1>, 1.0);

	}

}