// This script was made by PanteraPolnocy Resident, 5e9cbbb8-1aef-4692-bfc4-a53f8c8fcbc9
// Script template version used: 1.6

integer gDialogChannel;
integer gListenHandle;

// Use llInstantMessage() only when it's really neccessary
sendPrivMessage(key targetAvatar, string targetMsg)
{
	if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
	{
		// User in region, use a function without delay and better visibility in chat
		llRegionSayTo(targetAvatar, 0, targetMsg);
	}
	else
	{
		// User not in region, use long-range function with 2 seconds delay
		llInstantMessage(targetAvatar, targetMsg);
	}
}

stopListener()
{
	llSetTimerEvent(0);
	llListenRemove(gListenHandle);
}

// Script starts here
default
{

	state_entry()
	{
		gDialogChannel = (integer)(llFrand(-10000000)-10000000);
		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}
	}

	listen(integer channel, string name, key id, string message)
	{
		stopListener();
	}

	touch_start(integer total_number)
	{
		key toucherKey = llDetectedKey(0);
		gListenHandle = llListen(gDialogChannel, "", toucherKey, "");
		llDialog(toucherKey, "\nMew.", ["Mew", "Purr", "Cookies"], gDialogChannel);
		llSetTimerEvent(60);
	}

	timer()
	{
		stopListener();
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}