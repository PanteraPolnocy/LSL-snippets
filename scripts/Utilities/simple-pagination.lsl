// Written by PanteraPolnocy

list gMeepers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"];
integer gPageNum;
integer gListenHandle;
integer gListLength;

openmenu()
{

	gListenHandle = llListen(-123, "", llGetOwner(), "");
	integer startCut = gPageNum * 9;
	integer endCut = startCut + 8;

	if (endCut >= gListLength)
	{
		endCut = gListLength;
	}

	list options = llList2List(gMeepers, startCut, endCut);
	options = "Next >" + options;
	options = "..." + options;
	options = "< Prev" + options;

	llDialog(llGetOwner(), "\nMew.", options, -123);
	llSetTimerEvent(120);

}

stoplisteners()
{
	llListenRemove(gListenHandle);
	llSetTimerEvent(0);
}

default
{

	state_entry()
	{
		gListLength = llGetListLength(gMeepers);
	}

	touch_start(integer total_number)
	{
		gPageNum = 0;
		openmenu();
	}

	listen(integer channel, string name, key id, string message)
	{
		if (message == "< Prev")
		{
			if (gPageNum > 0)
			{
				--gPageNum;
			}
			openmenu();
		}
		else if (message == "Next >")
		{
			if (gPageNum < llCeil(gListLength/9))
			{
				++gPageNum;
			}
			openmenu();
		}
		else if (message == "...")
		{
			openmenu();
		}
		else
		{
			llSay(0, message);
		}
	}

	timer()
	{
		stoplisteners();
	}

}
