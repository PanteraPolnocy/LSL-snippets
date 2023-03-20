// Written by Pantera

float gMinimumDistance = 10; // Minimum distance in meters; Set 0 to disable
key gMatchGroup = ""; // Group key, only people with active group would be able to get contents; Set to empty to disable
integer gAgeLimit = 0; // Maximum age to get items; Set 0 to disable

// =======================================

list gUsersWhoAlreadyTookItem;
list gInv;
integer gInvLength;
integer gCounter;
key gAgeQueryId;
key gPassItemsToAvatar;

giveItems(key toWho)
{

	string objectName = llGetObjectName();
	llRegionSayTo(toWho, 0, "Here are your items. Check for folder named '" + objectName + "' in your inventory.");
	llGiveInventoryList(toWho, objectName, gInv);
	++gCounter;

	gUsersWhoAlreadyTookItem += toWho;
	if (llGetFreeMemory() < 27000) // Remove oldest entry - stack/heap collision crash guard
	{
		gUsersWhoAlreadyTookItem = llDeleteSubList(gUsersWhoAlreadyTookItem, 0, 1);
	}

}

default
{

	state_entry()
	{
		gInv = [];
		integer i = 0;
		integer max = llGetInventoryNumber(INVENTORY_ALL);
		string thisScriptName = llGetScriptName();
		for (i=0; i<max; ++i)
		{
			string currentInventoryName = llGetInventoryName(INVENTORY_ALL, i);
			if (thisScriptName != currentInventoryName)
			{
				gInv = gInv + currentInventoryName;
			}
		}
		gInvLength = llGetListLength(gInv);
	}

	touch_start(integer total_number)
	{

		key targetAvatar = llDetectedKey(0);

		if (llGetAgentSize(targetAvatar) == ZERO_VECTOR)
		{
			llInstantMessage(targetAvatar, "I'm sorry, but you need to be in the same region as me. Please, come closer.");
			return;
		}

		if (targetAvatar == llGetOwner())
		{
			llRegionSayTo(targetAvatar, 0, "Gifts given so far: " + (string)gCounter);
			return;
		}

		if (gInvLength <= 0)
		{
			llRegionSayTo(targetAvatar, 0, "Sorry, nothing to give.");
			return;
		}

		if (~llListFindList(gUsersWhoAlreadyTookItem, (list)targetAvatar))
		{
			llRegionSayTo(targetAvatar, 0, "It seems that you have already received items. Check your inventory.");
			return;
		}

		if (gMinimumDistance > 0 && llVecDist(llGetPos(), llDetectedPos(0)) > gMinimumDistance)
		{
			llRegionSayTo(targetAvatar, 0, "Sorry, but you are too far away. Please, come closer.");
			return;
		}

		if (gMatchGroup != NULL_KEY && gMatchGroup != "")
		{
			list avatarAttachments = llGetAttachedList(targetAvatar);
			if (llGetListLength(avatarAttachments) > 0)
			{
				if (llList2Key(llGetObjectDetails(llList2Key(avatarAttachments, 0), [OBJECT_GROUP]), 0) != gMatchGroup)
				{
					llRegionSayTo(targetAvatar, 0, "Sorry, but you need to activate secondlife:///app/group/" + (string)gMatchGroup + "/about group in order to get items.");
					return;
				}
			}
			else
			{
				llRegionSayTo(targetAvatar, 0, "Sorry, but I cannot determine your active group. Please wear any attachment, at least for a moment, and try again.");
				return;
			}
		}

		if (gAgeLimit > 0)
		{
			gPassItemsToAvatar = targetAvatar;
			gAgeQueryId = llRequestAgentData(gPassItemsToAvatar, DATA_BORN);
			return;
		}

		giveItems(targetAvatar);

	}

	changed(integer change)
	{
		if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
		{
			llResetScript();
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	dataserver(key queryid, string data)
	{
		if (gAgeQueryId == queryid)
		{

			// I found these calculations somewhere online, but I have no idea where and when
			// Then cleaned them up

			list l = llParseString2List(data, ["-"], []);
			integer Y = (integer)llList2String(l, 0);
			integer M = (integer)llList2String(l, 1);
			integer D = (integer)llList2String(l, 2);
			if (M == 1 || M == 2)
			{
				--Y;
				M += 12;
			}
			integer A = Y / 100;
			integer B = A / 4;
			integer C = 2 - A - B;
			float E = 365.25 * (Y + 4716);
			float F = 30.6001 * (M + 1);
			integer age = C + D + (integer)E + (integer)F - 1524;

			l = llParseString2List(llGetDate(), ["-"], []);
			Y = (integer)llList2String(l, 0);
			M = (integer)llList2String(l, 1);
			D = (integer)llList2String(l, 2);
			if (M == 1 || M == 2)
			{
				--Y;
				M += 12;
			}
			A = Y / 100;
			B = A / 4;
			C = 2 - A - B;
			E = 365.25 * (Y + 4716);
			F = 30.6001 * (M + 1);

			integer finalAge = C + D + (integer)E + (integer)F - 1524 - age;

			if (finalAge <= gAgeLimit)
			{
				giveItems(gPassItemsToAvatar);
			}
			else
			{
				llRegionSayTo(gPassItemsToAvatar, 0, "I'm sorry, but you are too old to get contents of this object. I'm meant to give things for people up to " + (string)gAgeLimit + " days old.");
			}

		}
	}

}
