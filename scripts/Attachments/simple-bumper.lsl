// Written by PanteraPolnocy

key gSound = "6e378d3f-5df3-f58d-ebf4-7614f77c5422";

default
{
	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		llPreloadSound(gSound);
		llSetMemoryLimit(llGetUsedMemory() + 1024);
	}

	collision_start(integer nd)
	{
		llTriggerSound(gSound, 1);
	}
}
