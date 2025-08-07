integer gIsVisible = TRUE;
integer gAnimationPermsGiven;
string gAnimationDraw = "Draw";
string gAnimationSheath = "Sheath";
string gSoundDraw = "81266a70-27f1-56c9-fc57-5b353ac93c69";
string gSoundSheath = "6e378d3f-5df3-f58d-ebf4-7614f77c5422";

showHide()
{
	llSetLinkAlpha(LINK_SET, (float)gIsVisible, ALL_SIDES);
	integer numberOfPrims = llGetNumberOfPrims();
	integer currentPrim;
	while (currentPrim <= numberOfPrims)
	{
		integer faceCount = llGetLinkNumberOfSides(currentPrim);
		integer i;
		for(; i < faceCount; ++i)
		{
			list transforms = llGetLinkPrimitiveParams(currentPrim, [PRIM_GLTF_BASE_COLOR, i]);
			list pending = [
				PRIM_GLTF_BASE_COLOR,
				i,
				llList2String(transforms, 0),
				(vector)llList2String(transforms, 1),
				(vector)llList2String(transforms, 2),
				(float)llList2String(transforms, 3),
				(vector)llList2String(transforms, 4),
				"",
				PRIM_GLTF_ALPHA_MODE_BLEND,
				(float)llList2String(transforms, 7),
				(integer)llList2String(transforms, 8)
			];
			if (!gIsVisible)
			{
				pending = llListReplaceList(pending, [(float)0.0], 7, 7);
			}
			llSetLinkPrimitiveParamsFast(currentPrim, pending);
		}
		++currentPrim;
	}
}

default
{

	state_entry()
	{
		if (llGetAttached())
		{
			llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
		}
		llSetMemoryLimit(llGetUsedMemory() + 10240);
		showHide();
	}

	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_TRIGGER_ANIMATION)
		{
			gAnimationPermsGiven = TRUE;
		}
	}

	touch_start(integer total_number)
	{
		if (llDetectedKey(0) == llGetOwner())
		{
			gIsVisible = !gIsVisible;
			if (gIsVisible)
			{
				if (gAnimationPermsGiven)
				{
					llStopAnimation(gAnimationDraw);
					llStartAnimation(gAnimationSheath);
				}
				llTriggerSound(gSoundSheath, 1);
				llSay(-453652, "hideblade");
			}
			else
			{
				if (gAnimationPermsGiven)
				{
					llStopAnimation(gAnimationSheath);
					llStartAnimation(gAnimationDraw);
				}
				llTriggerSound(gSoundDraw, 1);
				llSay(-453652, "showblade");
			}
			showHide();
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}


====================================
====================================
====================================


showHide(integer isVisible)
{
	llSetLinkAlpha(LINK_SET, (float)isVisible, ALL_SIDES);
	integer numberOfPrims = llGetNumberOfPrims();
	integer currentPrim;
	while (currentPrim <= numberOfPrims)
	{
		integer faceCount = llGetLinkNumberOfSides(currentPrim);
		integer i;
		for(; i < faceCount; ++i)
		{
			list transforms = llGetLinkPrimitiveParams(currentPrim, [PRIM_GLTF_BASE_COLOR, i]);
			list pending = [
				PRIM_GLTF_BASE_COLOR,
				i,
				llList2String(transforms, 0),
				(vector)llList2String(transforms, 1),
				(vector)llList2String(transforms, 2),
				(float)llList2String(transforms, 3),
				(vector)llList2String(transforms, 4),
				"",
				PRIM_GLTF_ALPHA_MODE_BLEND,
				(float)llList2String(transforms, 7),
				(integer)llList2String(transforms, 8)
			];
			if (!isVisible)
			{
				pending = llListReplaceList(pending, [(float)0.0], 7, 7);
			}
			llSetLinkPrimitiveParamsFast(currentPrim, pending);
		}
		++currentPrim;
	}
}

default
{

	state_entry()
	{
		llListen(-453652, "", NULL_KEY, "");
		llSetMemoryLimit(llGetUsedMemory() + 10240);
		showHide(FALSE);
	}

	listen(integer channel, string name, key id, string message)
	{
		if (llGetOwnerKey(id) == llGetOwner())
		{
			if (message == "showblade" || message == "hideblade")
			{
				if (message == "showblade")
				{
					showHide(TRUE);
				}
				else if (message == "hideblade")
				{
					showHide(FALSE);
				}
			}
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}