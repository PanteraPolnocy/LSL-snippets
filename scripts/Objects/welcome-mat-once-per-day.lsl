// Written by PanteraPolnocy

list gVisitorsList = [];
integer gCleanedTodayAlready;
key gOwnerKey;

calcScriptMemoryLimit()
{
	integer usedMemory = llGetUsedMemory();
	if (usedMemory < 60416)
	{
		llSetMemoryLimit(usedMemory + 5120);
	}
}

default
{

	state_entry()
	{
		gOwnerKey = llGetOwner();
		llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHANTOM, FALSE, PRIM_PHYSICS, FALSE]);
		llVolumeDetect(TRUE);
		llSetTimerEvent(600);
		calcScriptMemoryLimit();
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	collision_start(integer num)
	{

		string visitorKey = llDetectedKey(0);
		if (llListFindList(gVisitorsList, (list)visitorKey) == -1)
		{
			gVisitorsList = gVisitorsList + visitorKey;
			llRegionSayTo(visitorKey, 0, "Welcome in the store, secondlife:///app/agent/" + visitorKey + "/about.");
			calcScriptMemoryLimit();
		}

		if (visitorKey == gOwnerKey)
		{
			llOwnerSay("Visitors since midnight Pacific time, including owner: " + (string)llGetListLength(gVisitorsList));
		}

	}

	timer()
	{
		if (llGetWallclock() < 1000)
		{
			if (gCleanedTodayAlready == 0)
			{
				gCleanedTodayAlready = 1;
				gVisitorsList = [];
				calcScriptMemoryLimit();
			}
		}
		else if (gCleanedTodayAlready == 1)
		{
			gCleanedTodayAlready = 0;
		}
	}

}
