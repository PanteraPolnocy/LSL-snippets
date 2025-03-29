// Written by PanteraPolnocy for Firestorm team

integer gAvatarsLimitInHoverText = 10;

getData()
{

	list avatarsInRegion = llGetAgentList(AGENT_LIST_REGION, []);
	integer numOfAvatars = llGetListLength(avatarsInRegion);
	string setTextValue = "[ Region: " + (string)numOfAvatars + " ]\n";

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

		string cache = llLinksetDataRead("avlang:" + (string)id);
		if (cache != "" && llJsonValueType(cache, []) != JSON_INVALID)
		{
			avName = llJsonGetValue(cache, [0]);
			avLang = llJsonGetValue(cache, [1]);
		}
		else
		{
			avName = llKey2Name(id);
			avName = llGetSubString(avName, 0, (llSubStringIndex(avName, " ") - 1));
			avLang = llStringTrim(llGetAgentLanguage(id), STRING_TRIM);
			if (avLang == "en-us" || avLang == "en-gb")
			{
				avLang = "en";
			}
			else if (avLang == "")
			{
				avLang = "xx";
			}
			llLinksetDataWrite("avlang:" + (string)id, llList2Json(JSON_ARRAY, [avName, avLang]));
		}

		setTextValue = setTextValue + avName + " (" + avLang + ", " + (string)avDist + "m)\n";
		index = index + 2;

	}

	avatarsInRegion = [];
	llSetText(setTextValue, <1, 1, 1>, 1.0);

	if (llLinksetDataCountFound("^avlang:") > 100)
	{
		list forDeletion = llLinksetDataFindKeys("^avlang:", 0, 20);
		index = 0;
		while (index < 20)
		{
			llLinksetDataDelete(llList2String(forDeletion, 0));
			++index;
		}
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
		llLinksetDataDeleteFound("^avlang:", "");
		getData();
		llSetTimerEvent(10);
	}

	timer()
	{
		getData();
	}

}