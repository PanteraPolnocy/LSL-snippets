// Written by PanteraPolnocy

// Format: Face, Link URL, Texture UUID (only used on script boot)
list gData = [
	0, "https://www.google.com", "f2f807ce-c5f9-2156-eb03-f36a3c976a83",
	1, "https://www.duckduckgo.com", "5a0538f5-23c7-b76c-7115-905cb4f8beb2",
	2, "https://www.bing.com", "10522cbd-8d18-3ba0-0043-782018b086b1"
];

list gIndexes;

default
{
	state_entry()
	{
		// Set some faces on the prim to the correct textures
		integer dataLength = llGetListLength(gData);
		integer index;
		while (index < dataLength)
		{
			llSetTexture(llList2String(gData, (index + 2)), llList2Integer(gData, index));
			index += 3;
		}

		// Build index list for faster lookups
		gIndexes = llList2ListStrided(gData, 0, -1, 3);
		// Optimization under Mono. Delete this line if you run into problems, or don't know what it does.
		llSetMemoryLimit(llGetUsedMemory() + 5120);
		// Say hello
		llOwnerSay("Touch me to go to a search engine!");
	}

	touch_start(integer total_number)
	{
		key toucherKey = llDetectedKey(0);
		integer indexPosition = llListFindList(gIndexes, (list)llDetectedTouchFace(0));
		if (~indexPosition)
		{
			// Get the URL from data list, by index position multiplied by stride length and added 1
			string url = llList2String(gData, (indexPosition * 3) + 1);
			// Send the URL to whoever touched me
			llRegionSayTo(toucherKey, 0, "Sending you to " + url);
			llLoadURL(toucherKey, "Navigate to " + url, url);
		}
		else
		{
			llRegionSayTo(toucherKey, 0, "I don't know what to do with that face!");
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}
}