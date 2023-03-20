// Written by PanteraPolnocy

string gEmailAddressTo = "youremailhere@gmail.com";
string gEmailSubject = "Email from Second Life inworld object";

integer gDialogChannel;
integer gListenHandle;
integer gIsBusy;

stopListener()
{
	llListenRemove(gListenHandle);
	llSetTimerEvent(0);
}

setDefaultHoverText(integer setIt)
{
	if (setIt)
	{
		llSetText("Click on me to send an e-mail message", <1, 1, 1>, 0.5);
	}
	else
	{
		llSetText("I'm busy right now, please wait...", <1, 1, 1>, 0.5);
	}
}

default
{
	state_entry()
	{
		gDialogChannel = (integer)(llFrand(-10000000)-10000000);
		setDefaultHoverText(TRUE);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	timer()
	{
		stopListener();
	}

	listen(integer channel, string name, key id, string message)
	{
		gIsBusy = TRUE;
		stopListener();
		setDefaultHoverText(FALSE);
		llEmail(gEmailAddressTo, name + ": " + gEmailSubject, message);
		setDefaultHoverText(TRUE);
		gIsBusy = FALSE;
	}

	touch_start(integer total_number)
	{
		if (!gIsBusy)
		{
			stopListener();
			key toucherKey = llDetectedKey(0);
			gListenHandle = llListen(gDialogChannel, "", toucherKey, "");
			llTextBox(toucherKey, "You have up to 120 seconds to write the message.", gDialogChannel);
			llSetTimerEvent(120);
		}
	}
}