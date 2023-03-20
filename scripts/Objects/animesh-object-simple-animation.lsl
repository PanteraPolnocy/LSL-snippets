// Written by PanteraPolnocy

string gAnimationName = "wiggle_whiskers_curiously_loop";

default
{

	state_entry()
	{
		list anims = llGetObjectAnimationNames();
		integer len = llGetListLength(anims);
		integer i;
		while (i < len)
		{
			llStopObjectAnimation(llList2String(anims, i));
			++i;
		}
		llStartObjectAnimation(gAnimationName);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}