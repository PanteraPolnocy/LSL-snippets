// Written by PanteraPolnocy

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		llSetText("", <1,1,1>, 0);
		llSleep(3);
		llRemoveInventory(llGetScriptName());
	}

}