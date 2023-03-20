// Written by PanteraPolnocy
// Set media param to the value from the child prim's description

float gMinimumTouchDistanceInMeters = 15;
integer gMediaFace = 1;

string gTheLink = "https://www.youtube.com";

applyMedia(string theString)
{
	llSetLinkMedia(LINK_THIS, gMediaFace, [
		PRIM_MEDIA_AUTO_PLAY, TRUE,
		PRIM_MEDIA_CURRENT_URL, theString,
		PRIM_MEDIA_HOME_URL, theString,
		PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_ANYONE,
		PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_ANYONE,
		PRIM_MEDIA_AUTO_ZOOM, TRUE,
		PRIM_MEDIA_AUTO_SCALE, TRUE,
		PRIM_MEDIA_HEIGHT_PIXELS, 1024,
		PRIM_MEDIA_WIDTH_PIXELS, 1024,
		PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI
	]);
}

// Use llInstantMessage() only when it's really neccessary
sendPrivMessage(key targetAvatar, string targetMsg)
{
	if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
	{
		// User in region, use a function without delay and better visibility in chat
		llRegionSayTo(targetAvatar, 0, targetMsg);
	}
	else
	{
		// User not in region, use long-range function with 2 seconds delay
		llInstantMessage(targetAvatar, targetMsg);
	}
}

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		applyMedia(gTheLink);
		llPassTouches(PASS_ALWAYS);
		llSetMemoryLimit(llGetUsedMemory() + (1024 * 10));
	}

	touch_start(integer num_detected)
	{

		key toucherKey = llDetectedKey(0);
		if (llVecDist(llGetPos(), llDetectedPos(0)) > gMinimumTouchDistanceInMeters)
		{
			sendPrivMessage(toucherKey, "You're too far away or not in the same region, please come closer.");
			return;
		}

		integer linkNumber = llDetectedLinkNumber(0);
		if (linkNumber == LINK_ROOT)
		{
			return;
		}

		string childPrimDescription = llList2String(llGetLinkPrimitiveParams(linkNumber, [PRIM_DESC]), 0);
		childPrimDescription = llStringTrim(childPrimDescription, STRING_TRIM);
		if (childPrimDescription == "" || llSubStringIndex(childPrimDescription, "http") != 0)
		{
			sendPrivMessage(toucherKey, "This button has no valid URL assigned.");
			return;
		}

		sendPrivMessage(toucherKey, "Changing URL...");
		applyMedia(childPrimDescription);

	}

}