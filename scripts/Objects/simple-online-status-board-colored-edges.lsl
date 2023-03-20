// Written by PanteraPolnocy

key gOwnerKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
string gMainImageUUID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// Nothing to change below this line!
integer gIsOnline = 2;
key gOnlineCheck;

checkOnline()
{
	gOnlineCheck = llRequestAgentData(gOwnerKey, DATA_ONLINE);
}

makeOnline()
{
	llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0.18, 0.8, 0.251>, 1]);
	llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, 0, <1, 1, 1>, 1]);
}

makeOffline()
{
	llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1, 0.255, 0.212>, 1]);
	llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, 0, <1, 1, 1>, 1]);
}

// Script starts here
default
{

	state_entry()
	{

		llSetLinkTexture(LINK_THIS, gMainImageUUID, 0);
		llSetTimerEvent(60);
		checkOnline();

		// Some memory management here, with mininum 20KB buffer
		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}

	}

	touch_start(integer total_number)
	{
		string currentstatus;
		if (gIsOnline == 1)
		{
			currentstatus = "ONLINE";
		}
		else
		{
			currentstatus = "OFFLINE";
		}
		llRegionSayTo(llDetectedKey(0), 0, "My profile: secondlife:///app/agent/" + (string)gOwnerKey + "/about - you can open it by clicking on link in chat and then send me a message if you wish. Currently I am " + currentstatus + " .");
	}

	timer()
	{
		checkOnline();
	}

	dataserver(key request, string data)
	{
		if (gOnlineCheck == request)
		{
			if (data == "1" && gIsOnline != 1)
			{
				gIsOnline = 1;
				makeOnline();
			}
			else if (data == "0" && gIsOnline != 0)
			{
				gIsOnline = 0;
				makeOffline();
			}
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}