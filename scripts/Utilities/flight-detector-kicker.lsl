// Written by PanteraPolnocy

key gOwnerKey;
integer gActionMode;

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			llResetScript();
		}
	}

	state_entry()
	{
		gOwnerKey = llGetOwner();
		llSetTimerEvent(30);
		llOwnerSay("Mode: Send a message each 30 seconds to a flying avatar.");
	}

	touch_start(integer total_number)
	{
		if (llDetectedKey(0) == gOwnerKey)
		{
			if (gActionMode == 0)
			{
				gActionMode = 1;
				llOwnerSay("Mode: Scan region each 30 seconds, send a message and autokick (send to home) if flying detected. This mode needs proper object permissions: http://wiki.secondlife.com/wiki/LlTeleportAgentHome#Ownership_Limitations");
			}
			else
			{
				gActionMode = 0;
				llOwnerSay("Mode: Send a message each 30 seconds to a flying avatar.");
			}
		}
	}

	timer()
	{
		list avatarsInParcel = llGetAgentList(AGENT_LIST_PARCEL, []);
		integer numOfAvatars = llGetListLength(avatarsInParcel);
		if (numOfAvatars > 0)
		{
			integer index;
			while (index < numOfAvatars)
			{
				key agentKey = llList2Key(avatarsInParcel, index);
				if (llGetAgentInfo(agentKey) & AGENT_FLYING)
				{
					if (agentKey != gOwnerKey)
					{
						llRegionSayTo(agentKey, 0, "PLEASE DON'T FLY IN THIS PARCEL.");
						if (gActionMode == 1)
						{
							llTeleportAgentHome(agentKey);
						}
					}
				}
				++index;
			}
		}
	}

}
