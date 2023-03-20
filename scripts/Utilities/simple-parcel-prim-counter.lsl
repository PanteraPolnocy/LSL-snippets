// Written by PanteraPolnocy

string gMessage = "Hello there good citizen! It seems, that you use prims in a bit excessive way. Please do consider cleaning up some stuff to be below [LIMIT] if possible, pretty please. :3~";

float gX;
float gY;
list gParcelOwners;
list gUsers;
list gPrims;

key gNotecardQueryId;
integer gNotecardLine;
string gNotecardName = "config";

string searchAndReplace(string input, string old, string new)
{
	return llDumpList2String(llParseString2List(input, [old], []), new);
}

scanPrims()
{

	llOwnerSay("Starting prim scan, please wait...");
	gX = 2.0;
	gY = 2.0;

	while (gY <= 256.0)
	{

		key parcelOwner = llList2Key(llGetParcelDetails(<gX, gY, 100.0>, [PARCEL_DETAILS_OWNER]), 0);
		if (!~llListFindList(gParcelOwners, [parcelOwner]))
		{
			gParcelOwners = gParcelOwners + parcelOwner;
			integer testPos = llListFindList(gUsers, [parcelOwner]);
			if (testPos != -1)
			{
				integer primLimit = llList2Integer(gPrims, testPos);
				if (llGetParcelPrimCount(<gX, gY, 100.0>, PARCEL_COUNT_TOTAL, TRUE) > primLimit)
				{
					if (llGetAgentSize(parcelOwner) != ZERO_VECTOR)
					{
						llRegionSayTo(parcelOwner, 0, searchAndReplace(gMessage, "[LIMIT]", (string)primLimit));
					}
					else
					{
						llInstantMessage(parcelOwner, searchAndReplace(gMessage, "[LIMIT]", (string)primLimit));
					}
				}
			}
		}

		if (gX <= 256.0)
		{
			gX +=2.0;
		}
		else
		{
			gY += 2.0;
			gX = 2.0;
		}

	}

	llOwnerSay("Prim scan finished.");

}

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		if (llGetInventoryKey(gNotecardName) == NULL_KEY)
		{
			llOwnerSay("Notecard '" + gNotecardName + "' with avatar keys missing or unwritten.");
		}
		else
		{
			gNotecardQueryId = llGetNotecardLine(gNotecardName, 0);
		}
	}

	dataserver(key request_id, string data)
	{
		if (request_id == gNotecardQueryId)
		{
			if (data == EOF)
			{
				llOwnerSay("Notecard read, " + (string)gNotecardLine + " lines. Starting scanners.");
				scanPrims();
				llSetTimerEvent(3600 * 24);
				llSetMemoryLimit(llGetUsedMemory() + 5120);
				return;
			}
			else if (data != "")
			{
				list params = llParseString2List(data, [":"], []);
				gUsers = gUsers + llList2Key(params, 0);
				gPrims = gPrims + llList2Integer(params, 1);
			}
			gNotecardQueryId = llGetNotecardLine(gNotecardName, ++gNotecardLine);
		}
	}

	timer()
	{
		scanPrims();
	}

	changed(integer change)
	{
		if (change & (CHANGED_ALLOWED_DROP | CHANGED_INVENTORY | CHANGED_OWNER))
		{
			llResetScript();
		}
	}

}