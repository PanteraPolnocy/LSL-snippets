// Written by PanteraPolnocy
// Older script

default
{
	state_entry()
	{
		llCreateCharacter([CHARACTER_DESIRED_SPEED, 35.0, CHARACTER_MAX_SPEED, 35.0]);
		llPursue(llGetOwner(), [PURSUIT_OFFSET, <-2.0, 0.0, 0.0>, PURSUIT_FUZZ_FACTOR, 0.2]);
		llSetTimerEvent(15);
	}
	timer()
	{
		llResetScript();
	}
}