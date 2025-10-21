// This script was made by PanteraPolnocy Resident, 5e9cbbb8-1aef-4692-bfc4-a53f8c8fcbc9

// Hardcoded here, but can be pulled via other method
vector gDefaultRootPrimSize = <1.17, 0.76, 1.67>;

integer gDialogChannel;
integer gListenHandle;

stopListener()
{
	llSetTimerEvent(0);
	llListenRemove(gListenHandle);
}

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
		llOwnerSay(message);
		vector currentScale = llGetScale();
		float currentFactor = currentScale.x / gDefaultRootPrimSize.x;
		float targetFactor;
		if (message == "Default scale")
		{
			targetFactor = 1.0 / currentFactor;
		}
		else if (llGetSubString(message, 0, 5) == "Scale:")
		{
			targetFactor = (float)llStringTrim(llGetSubString(message, 6, -1), STRING_TRIM) / currentFactor;
		}
		llScaleByFactor(targetFactor);
		stopListener();
	}

	touch_start(integer total_number)
	{
		key toucherKey = llDetectedKey(0);
		gListenHandle = llListen(gDialogChannel, "", toucherKey, "");
		llDialog(toucherKey, "\nMew.", ["Default scale", "Scale: 2.0", "Scale: 2.5", "Scale: 3.0", "Scale: 5.0"], gDialogChannel);
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
