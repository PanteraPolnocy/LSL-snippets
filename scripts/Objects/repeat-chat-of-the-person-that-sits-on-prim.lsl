// Written by PanteraPolnocy

integer listener;

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_LINK)
		{
			llListenRemove(listener);
			key av = llAvatarOnSitTarget();
			if (av)
			{
				listener = llListen(0, "", av, "");
			}
		}
	}

	listen(integer channel, string name, key id, string message)
	{
		llSay(0, message);
	}

}
