// Written by PanteraPolnocy

string gOriginalObjectName;
key gOwnerKey;

default
{

	state_entry()
	{

		gOwnerKey = llGetOwner();
		gOriginalObjectName = llGetObjectName();
		llListen(345325, "", gOwnerKey, "");
		llOwnerSay("@redirchat:345325=add,rediremote:345325=add");

		// Work: non-script zones. See run_time_permissions().
		if (llGetAttached() != 0)
		{
			llRequestPermissions(gOwnerKey, PERMISSION_TAKE_CONTROLS);
		}

		// Some memory management here, with mininum 20KB buffer
		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}

	}

	listen(integer channel, string name, key id, string message)
	{
		llSetObjectName("Fluffy box");
		llSay(0, message);
		llSetObjectName(gOriginalObjectName);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_TAKE_CONTROLS)
		{
			// Take control for value that does nothing, in order to work in no-script sims
			llTakeControls(1024, TRUE, TRUE);
		}
	}

}
