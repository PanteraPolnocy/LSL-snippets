// Written by PanteraPolnocy

string gLastRegion;
string gSimulator;
list gLast50FPS;
string gLastRestart = "TBD after next restart";
string gSimRating = "unknown";

default
{

	state_entry()
	{

		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}

		llSetText("Gathering data, please wait...", <1, 1, 1>, 0.75);
		llOwnerSay("Data check each 60 seconds.");
		llSetTimerEvent(60);

	}

	timer()
	{

		string currentPlace = llGetRegionName();
		if (gLastRegion != currentPlace)
		{
			gSimulator = llGetSimulatorHostname();
			gLastRegion = currentPlace;
			llRequestSimulatorData(gLastRegion, DATA_SIM_RATING);
		}

		integer regionFPS = (integer)llGetRegionFPS();
		string regionStat = "very good";
		vector textColor = <0, 1, 0>;
		if (regionFPS < 10)
		{
			regionStat = "crash possible";
			textColor = <1, 0, 0>;
		}
		else if (regionFPS < 25)
		{
			regionStat = "slow";
			textColor = <1, 1, 0>;
		}
		else if (regionFPS < 35)
		{
			regionStat = "good";
		}

		integer i;
		integer regionsFPSTotal;
		integer regionsFPSListLength = llGetListLength(gLast50FPS);
		if (regionsFPSListLength == 50)
		{
			gLast50FPS = llDeleteSubList(gLast50FPS, 0, 0);
		}
		else
		{
			++regionsFPSListLength;
		}
		gLast50FPS = gLast50FPS + regionFPS;
		while (regionsFPSListLength > i)
		{
			regionsFPSTotal = regionsFPSTotal + llList2Integer(gLast50FPS, i);
			++i;
		}

		llSetText(
			"Region name: '" + gLastRegion + "' (" + gSimRating + ")\n" +
			"Sim hostname: '" + gSimulator + "'\n" +
			llGetEnv("sim_channel") + " " + llGetEnv("sim_version") + "\n" +
			"Last restart: " + gLastRestart + "\n" +
			"FPS: " + (string)regionFPS + " current (" + regionStat + "), " + (string)llRound(regionsFPSTotal / regionsFPSListLength) + " average\n" +
			"Time dilation: " + (string)llGetRegionTimeDilation() + "\n" +
			"Avatars: " + (string)llGetRegionAgentCount()
		, textColor, 0.75);

	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	dataserver(key query_id, string data)
	{
		gSimRating = llToLower(data);
	}

	changed(integer change)
	{
		if (change & CHANGED_REGION_START)
		{
			list timestamp = llParseString2List(llGetTimestamp(), [".", "T"], []);
			gLastRestart = llList2String(timestamp, 0) + ", " + llList2String(timestamp, 1) + " (UTC)";
		}
	}

}