// Written by PanteraPolnocy

default
{

	state_entry()
	{
		llSetMemoryLimit(llGetUsedMemory() + 2048);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	touch_start(integer total_number)
	{
		string targetMsg = "Click the link in chat to visit [https://marketplace.secondlife.com/stores/200251 my store] on Second Life Marketplace.";
		key targetAvatar = llDetectedKey(0);
		if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
		{
			llRegionSayTo(targetAvatar, 0, targetMsg);
		}
		else
		{
			llInstantMessage(targetAvatar, targetMsg);
		}
	}

}