// Written by PanteraPolnocy

// Target language code - format is ISO 639-1, two letters
string gTargetLanguage = "en";
integer gMediaFace = 0;

default
{
	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		llSetPrimMediaParams(gMediaFace, [
			PRIM_MEDIA_AUTO_PLAY, TRUE,
			PRIM_MEDIA_CURRENT_URL, "https://translate.google.com",
			PRIM_MEDIA_HOME_URL, "https://translate.google.com",
			PRIM_MEDIA_HEIGHT_PIXELS, 512,
			PRIM_MEDIA_WIDTH_PIXELS, 1024,
			PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
			PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER,
			PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_OWNER
		]);
		llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
		llOwnerSay("Listener ready. Remember to take me off when I'm not needed.");
	}

	listen(integer channel, string name, key id, string message)
	{
		if (llGetAgentSize(id) != ZERO_VECTOR)
		{
			llSetPrimMediaParams(gMediaFace, [
				PRIM_MEDIA_CURRENT_URL,
				llGetSubString("https://translate.google.com/?sl=auto&tl=" + gTargetLanguage + "&text=" + message + "&op=translate", 0, 1023)
			]);
		}
	}

}