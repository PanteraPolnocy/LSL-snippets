// Written by PanteraPolnocy for Firestorm team

integer gAvatarsLimitInHoverText = 10;
integer gRefreshRateInSeconds = 10;

list gCacheAvatarKeys;
list gCacheAvatarName;
list gCacheAvatarLang;

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		llSetText("Language detector is starting up...\n(refreshing each " + (string)gRefreshRateInSeconds + " seconds)", <1, 1, 1>, 1.0);
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
					tempKeys = tempKeys + [llRound(llVecDist(currentPos, llList2Vector(llGetObjectDetails(thisAvKey, [OBJECT_POS]), 0))), thisAvKey];
				}
				++index;
			}

			avatarsInRegion = llListSort(tempKeys, 2, TRUE);
			thisAvKey = NULL_KEY;
			tempKeys = [];
			numOfAvatars = llGetListLength(avatarsInRegion);
			index = 0;

			// --- PROCESSING

			while (index < numOfAvatars && index <= ((gAvatarsLimitInHoverText - 1) * 2))
			{

				string avName;
				string avLang;
				integer avDist = llList2Integer(avatarsInRegion, index);
				key id = llList2Key(avatarsInRegion, index + 1);

				integer listIndex = llListFindList(gCacheAvatarKeys, (list)id);
				if (listIndex != -1)
				{
					avName = llList2String(gCacheAvatarName, listIndex);
					avLang = llList2String(gCacheAvatarLang, listIndex);
				}
				else
				{
					avName = llKey2Name(id);
					avName = llGetSubString(avName, 0, (llSubStringIndex(avName, " ") - 1));
					avLang = llGetAgentLanguage(id);
					gCacheAvatarKeys = gCacheAvatarKeys + id;
					gCacheAvatarName = gCacheAvatarName + avName;
					gCacheAvatarLang = gCacheAvatarLang + avLang;
				}

				if (avLang == "en-us" || avLang == "en-gb" || avLang == "en")
				{
					avLang = "English";
				}
				else if (avLang == "da")
				{
					avLang = "Danish";
				}
				else if (avLang == "de")
				{
					avLang = "German";
				}
				else if (avLang == "es")
				{
					avLang = "Spanish";
				}
				else if (avLang == "fr")
				{
					avLang = "French";
				}
				else if (avLang == "it")
				{
					avLang = "Italian";
				}
				else if (avLang == "hu")
				{
					avLang = "Hungarian";
				}
				else if (avLang == "nl")
				{
					avLang = "Dutch";
				}
				else if (avLang == "pl")
				{
					avLang = "Polish";
				}
				else if (avLang == "pt")
				{
					avLang = "Portuguese";
				}
				else if (avLang == "ru")
				{
					avLang = "Russian";
				}
				else if (avLang == "tr")
				{
					avLang = "Turkish";
				}
				else if (avLang == "uk")
				{
					avLang = "Ukrainian";
				}
				else if (avLang == "zh")
				{
					avLang = "Chinese";
				}
				else if (avLang == "ja")
				{
					avLang = "Japanese";
				}
				else if (avLang == "ko")
				{
					avLang = "Korean";
				}
				else
				{
					avLang = "n/a";
				}

				setTextValue = setTextValue + avName + " " + (string)avDist + "m " + avLang + "\n";
				index = index + 2;

			}
		}

		llSetText(setTextValue, <1, 1, 1>, 1.0);

		integer cleanupCheck = llGetListLength(gCacheAvatarKeys);
		if (cleanupCheck > 100)
		{
			integer itemsToRemove = cleanupCheck - 100;
			gCacheAvatarKeys = llDeleteSubList(gCacheAvatarKeys, 0, itemsToRemove);
			gCacheAvatarName = llDeleteSubList(gCacheAvatarName, 0, itemsToRemove);
			gCacheAvatarLang = llDeleteSubList(gCacheAvatarLang, 0, itemsToRemove);
		}

	}

}