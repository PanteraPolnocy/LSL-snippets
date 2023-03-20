// Written by PanteraPolnocy

list gAllowList = [
	"5e9cbbb8-1aef-4692-bfc4-a53f8c8fcbc9", // Pantera
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", // Key 2
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" // Key 3
];

default
{

	state_entry()
	{
		llSetClickAction(CLICK_ACTION_TOUCH);
		llSetMemoryLimit(llGetUsedMemory() + 2048);
	}

	touch_start(integer num_detected)
	{
		key av = llDetectedKey(0);
		if (llVecDist(llGetPos(), llDetectedPos(0)) > 3)
		{
			llRegionSayTo(av, 0, "You are too far away.");
			return;
		}
		else if (~llListFindList(gAllowList, (list)((string)av)))
		{
			llRequestExperiencePermissions(av, "");
		}
		else
		{
			llRegionSayTo(av, 0, "Access denied. You are not authorized to use this door.");
		}
	}

	experience_permissions(key agent)
	{
		llRegionSayTo(agent, 0, "Access granted. Welcome, secondlife:///app/agent/" + (string)agent + "/about");
		llTeleportAgent(agent, llGetInventoryName(INVENTORY_LANDMARK, 0), ZERO_VECTOR, ZERO_VECTOR);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}