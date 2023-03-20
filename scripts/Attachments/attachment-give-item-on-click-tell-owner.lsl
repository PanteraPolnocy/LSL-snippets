// Written by PanteraPolnocy

string gInventoryName = "cookie";

default
{
	on_rez(integer sp)
	{
		llSetMemoryLimit(llGetUsedMemory() + 2048);
	}

	touch_start(integer total_number)
	{
		key touchedBy = llDetectedKey(0);
		llOwnerSay("I was touched by secondlife:///app/agent/" + (string)touchedBy + "/about");
		llGiveInventory(touchedBy, gInventoryName);
	}
}
