// Written by PanteraPolnocy

default
{

	state_entry()
	{
		llSetMemoryLimit(llGetUsedMemory() + 1024);
	}

	touch_start(integer total_number)
	{
		llSay(0, "Roll 1d20: " + (string)llRound(llFrand(19) + 1));
	}

}