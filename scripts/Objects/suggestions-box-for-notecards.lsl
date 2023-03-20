// Written by PanteraPolnocy

key gOwner;
integer gNotecardCount;

setHoverText(integer sendIMtoOwner)
{
	gNotecardCount = llGetInventoryNumber(INVENTORY_NOTECARD);
	llSetText("Suggestions? Drop a notecard here\nAwaiting inside: " + (string)gNotecardCount, <1, 1, 1>, 0.75);
	if (sendIMtoOwner == 1)
	{
		string placeName = llList2String(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME]), 0);
		if (llGetAgentSize(gOwner) != ZERO_VECTOR)
		{
			// Owner in region, use a function without delay
			llRegionSayTo(gOwner, 0, "--- It seems, that suggestions count has changed for '" + placeName + "'. Total suggestion notecards in box: " + (string)gNotecardCount);
		}
		else
		{
			// Owner not in region, use long-range function with 2 seconds delay
			llInstantMessage(gOwner, "--- It seems, that suggestions count has changed for '" + placeName + "'. Total suggestion notecards in box: " + (string)gNotecardCount);
		}
	}
}

default
{

	state_entry()
	{
		gOwner = llGetOwner();
		llAllowInventoryDrop(TRUE);
		setHoverText(0);
	}

	changed(integer change)
	{
		if (change & (CHANGED_ALLOWED_DROP | CHANGED_INVENTORY))
		{

			string thisScriptName = llGetScriptName();
			list itemsToRemove = [];
			integer currentIndex = 0;
			integer allItems = llGetInventoryNumber(INVENTORY_ALL);

			// We don't want items other, than notecards... yet, don't remove THIS script
			while (allItems > currentIndex)
			{
				string itemName = llGetInventoryName(INVENTORY_ALL, currentIndex);
				integer inventoryType = llGetInventoryType(itemName);
				if (inventoryType != INVENTORY_NOTECARD && itemName != thisScriptName)
				{
					itemsToRemove = [itemName] + itemsToRemove;
					// If it's another script, then stop it immediately! We don't want script injectors. ~
					if (inventoryType == INVENTORY_SCRIPT)
					{
						llSetScriptState(itemName, FALSE);
					}
				}
				++currentIndex;
			}

			currentIndex = 0;
			allItems = llGetListLength(itemsToRemove);

			// Do the actual removing...
			while (allItems > currentIndex)
			{
				llRemoveInventory(llList2String(itemsToRemove, currentIndex));
				++currentIndex;
			}

			// If notecard count has changed - inform the owner
			// If not - be sure that we have correct hovertext anyway, for example when someone tries to inject a script
			if (gNotecardCount != llGetInventoryNumber(INVENTORY_NOTECARD))
			{
				llWhisper(0, "Thank you for your suggestion!");
				setHoverText(1);
			}
			else
			{
				setHoverText(0);
			}

		}
		if (change & CHANGED_OWNER)
		{
			llResetScript();
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

}
