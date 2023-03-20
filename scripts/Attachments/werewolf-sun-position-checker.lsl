// Written by PanteraPolnocy

// RLV PROTOCOL MUST BE ENABLED!
// Set two directories - one for the human, one for the werewolf - with items, body shapes etc:
// inventorymainfolder/#RLV/werewolfme/wolf/
// inventorymainfolder/#RLV/werewolfme/human/
// Then add this script to any item, which will be present in both forms (inside a necklace or such).
// When Sun in SL will be below the horizon all things from the "wolf" folder will be attached, from the "human" - detached.
// When Sun in SL will be above the horizon all things from the "human" folder will be attached, from the "wolf" - detached.

integer dayTime = 3;
default
{

	on_rez(integer p)
	{
		llResetScript();
	}

	state_entry()
	{
		llSetTimerEvent(300);
	}

	timer()
	{
		vector s = llGetSunDirection();
		if (s.z < 0.0)
		{
			if (dayTime != 2)
			{
				dayTime = 2;
				llOwnerSay("@detach:werewolfme/human=force");
				llOwnerSay("@attach:werewolfme/wolf=force");
				// llOwnerSay("Werewolf form activated.");
			}
		}
		else if (s.z > 0.0)
		{
			if (dayTime != 1)
			{
				dayTime = 1;
				llOwnerSay("@detach:werewolfme/wolf=force");
				llOwnerSay("@attach:werewolfme/human=force");
				// llOwnerSay("Werewolf form deactivated.");
			}
		}
	}

}