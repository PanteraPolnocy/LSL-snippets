// Written by PanteraPolnocy

integer gListenHandle;
integer gDialogChannel;

stopListener()
{
	llListenRemove(gListenHandle);
	llSetTimerEvent(0);
}

default
{

	state_entry()
	{
		gDialogChannel = (integer)(llFrand(-1000000000)-1000000000);
		llSetMemoryLimit(llGetUsedMemory() + 5120);
	}

	listen(integer channel, string name, key id, string message)
	{
		llSetText(llStringTrim(message, STRING_TRIM), <1, 1, 1>, 1.0);
		stopListener();
	}

	touch_start(integer total_number)
	{
		key toucherKey = llDetectedKey(0);
		if (toucherKey == llGetOwner())
		{
			gListenHandle = llListen(gDialogChannel, "", toucherKey, "");
			llTextBox(toucherKey, "\nSet your title in the box below.", gDialogChannel);
			llSetTimerEvent(60);
		}
	}

	timer()
	{
		stopListener();
	}

}