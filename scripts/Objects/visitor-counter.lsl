// Written by PanteraPolnocy

string gStartMonthAndYear;
string gTempDay;
integer gAllVisits;
integer gTodayVisits;
list gRecentVisitors;

setText()
{
	llSetText((string)gTodayVisits + " visits today (UTC)\n" + (string)gAllVisits + " since " + gStartMonthAndYear, <1,1,1>, 0.3);
}

string getTempDay()
{
	return llList2String(llParseString2List(llGetDate(), ["-"], []), 2);
}

default
{

	state_entry()
	{

		list dateList = llParseString2List(llGetDate(), ["-"], []);
		gStartMonthAndYear = llList2String(
			["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
			llList2Integer(dateList, 1) - 1
		) + " " + llList2String(dateList, 0);

		gTempDay = getTempDay();
		llSetTimerEvent(20);
		llSensorRepeat("cake is a lie", NULL_KEY, AGENT_BY_LEGACY_NAME, 0.001, 0.001, 1800);
		setText();

	}

	no_sensor()
	{
		string dayNow = getTempDay();
		if (dayNow != gTempDay)
		{
			gTempDay = dayNow;
			gRecentVisitors = [];
			gTodayVisits = 0;
			setText();
		}
	}

	timer()
	{

		list avatarsInParcel = llGetAgentList(AGENT_LIST_PARCEL, []);
		integer numOfAvatars = llGetListLength(avatarsInParcel);
		if (!numOfAvatars)
		{
			return;
		}

		integer index;
		integer changesMade;
		while (index < numOfAvatars)
		{
			string avKey = llList2String(avatarsInParcel, index);
			if (llListFindList(gRecentVisitors, (list)avKey) == -1)
			{
				gRecentVisitors = gRecentVisitors + avKey;
				++gTodayVisits;
				++gAllVisits;
				changesMade = TRUE;
			}
			++index;
		}

		if (changesMade)
		{
			setText();
		}

	}

}
