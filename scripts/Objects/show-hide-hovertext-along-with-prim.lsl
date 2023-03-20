// Written by PanteraPolnocy

integer gListenHandle;

stopListener()
{
	llListenRemove(gListenHandle);
	llSetTimerEvent(0);
}

default
{
	touch_start(integer nd)
	{
		key toucherKey = llDetectedKey(0);
		if (toucherKey == llGetOwner())
		{
			gListenHandle = llListen(-1234567, "", toucherKey, "");
			llDialog(toucherKey, "Select an option", ["Show", "Hide"], -1234567);
			llSetTimerEvent(60);
		}
	}

	timer()
	{
		stopListener();
	}

	listen(integer channel, string name, key id, string message)
	{
		stopListener();
		string hoverText = llList2String(llGetPrimitiveParams([PRIM_TEXT]), 0);
		if (message == "Hide")
		{
			llSetLinkAlpha(LINK_SET, 0.0, ALL_SIDES);
			llSetText(hoverText, <1.0, 1.0, 1.0>, 0.0);
		}
		else if (message == "Show")
		{
			llSetLinkAlpha(LINK_SET, 1.0, ALL_SIDES);
			llSetText(hoverText, <1.0, 1.0, 1.0>, 1.0);
		}
	}

	on_rez(integer start_param)
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
}
