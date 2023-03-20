// Written by PanteraPolnocy

default
{

	state_entry()
	{
		llVolumeDetect(TRUE);
	}

	collision_start(integer total_number)
	{
		key userCollided = llDetectedKey(0);
		llRegionSayTo(userCollided, 0, "Please read over our rules that have been sent to you in a new folder");
		llGiveInventoryList(userCollided, llGetObjectName(), [llGetInventoryName(INVENTORY_LANDMARK, 0), llGetInventoryName(INVENTORY_NOTECARD, 0)]);
	}

}