default
{
	touch_start(integer total_number)
	{
		integer count = llLinksetDataCountKeys();

		if (count == 0)
		{
			llOwnerSay("LinksetData is empty.");
			return;
		}

		llOwnerSay("--- Starting LinksetData Dump (" + (string)count + " keys) ---");
		list allKeys = llLinksetDataListKeys(0, count);

		integer i;
		for (i = 0; i < count; i++)
		{
			string keyz = llList2String(allKeys, i);
			string value = llLinksetDataRead(keyz);
			llOwnerSay(keyz + " = " + value);
		}

		llOwnerSay("--- Dump Complete ---");
	}
}
