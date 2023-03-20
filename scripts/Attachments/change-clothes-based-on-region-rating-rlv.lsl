// Written by PanteraPolnocy

key gQuery;

// Setup:
// [inventory_root]/#RLV/swapitems/adult/[itemshere]
// [inventory_root]/#RLV/swapitems/moderate/[itemshere]
// [inventory_root]/#RLV/swapitems/pg/[itemshere]

string gFolderAdult = "swapitems/adult";
string gFolderModerate = "swapitems/moderate";
string gFolderPg = "swapitems/pg";

getRating()
{
	gQuery = llRequestSimulatorData(llGetRegionName(), DATA_SIM_RATING);
}

default
{

	on_rez(integer Setting)
	{
		llResetScript();
	}

	state_entry()
	{
		getRating();
	}

	changed(integer change)
	{
		if (change & (CHANGED_OWNER | CHANGED_REGION | CHANGED_TELEPORT))
		{
			getRating();
		}
	}

	dataserver(key query_id, string data)
	{
		if (query_id == gQuery)
		{
			if (data == "ADULT")
			{
				llOwnerSay("@attachallover:" + gFolderAdult + "=force,detachall:" + gFolderModerate + "=force,detachall:" + gFolderPg + "=force");
			}
			else if (data == "MATURE")
			{
				llOwnerSay("@detachall:" + gFolderAdult + "=force,attachallover:" + gFolderModerate + "=force,detachall:" + gFolderPg + "=force");
			}
			else // PG or UNKNOWN
			{
				llOwnerSay("@detachall:" + gFolderAdult + "=force,detachall:" + gFolderModerate + "=force,attachallover:" + gFolderPg + "=force");
			}
		}
	}

}