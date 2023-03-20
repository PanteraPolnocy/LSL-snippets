// Written by PanteraPolnocy

key gOwnerKey;
integer gDialogChannel;
integer gListenHandle;
string gGrapplingHookSound = "6fe65fd1-1f8b-99b2-cc1d-dfa8a056204e";

list gDetectedKeys;
list gDetectedNames;

teleportToKey(key tpUUID)
{

	list targetList = llGetObjectDetails(tpUUID, ([OBJECT_POS]));
	if (llGetListLength(targetList) != 1)
	{
		llOwnerSay("Out of range or wrong UUID.");
		return;
	}

	vector mttVector = llList2Vector(targetList, 0);
	vector relpos = mttVector - llGetPos();
	float groundLevel = llGround(relpos);
	if (mttVector.z < groundLevel)
	{
		mttVector.z = groundLevel + 1;
	}
	integer startTPTimer = llGetUnixTime();

	llTriggerSound(gGrapplingHookSound, 1);
	integer inTeleport = 1;
	while (inTeleport)
	{
		vector loc = llGetPos();
		vector targ = mttVector - loc;
		float dist = llVecMag(targ);
		if (dist < 1 || llGetUnixTime() - 10 > startTPTimer || mttVector == loc)
		{
			llStopMoveToTarget();
			inTeleport = 0;
		}
		else
		{
			if (dist < 65)
			{
				llMoveToTarget(mttVector, 0.05);
			}
			else
			{
				llMoveToTarget(loc+llVecNorm(targ)*60, 0.05);
			}
		}
		llSleep(0.05);
	}

}

default
{

	state_entry()
	{

		gOwnerKey = llGetOwner();
		gDialogChannel = (integer)(llFrand(-1000000000)-1000000000);
		llStopMoveToTarget();
		llPreloadSound(gGrapplingHookSound);

		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}

		if (llGetAttached() != 0)
		{
			llRequestPermissions(gOwnerKey, PERMISSION_TAKE_CONTROLS);
		}

	}

	listen(integer channel, string name, key id, string message)
	{
		if (message == "-Avatar-")
		{
			llSensor("", NULL_KEY, AGENT, 96, PI);
		}
		else if (message == "-Object-")
		{
			llSensor("", NULL_KEY, (PASSIVE | ACTIVE), 96, PI);
		}
		else if (message == "-UUID-")
		{
			llTextBox(gOwnerKey, "\nYou have 60 seconds to provide a valid prim or avatar UUID key in this region.", gDialogChannel);
		}
		else if (message == "-Up-")
		{
			llTriggerSound(gGrapplingHookSound, 1);
			integer i = 0;
			while (i < 5)
			{
				llApplyImpulse(<0, 0, 100000>, FALSE);
				llSleep(0.05);
				++i;
			}
		}
		else if ((key)message)
		{
			llOwnerSay("Hooking to key...");
			teleportToKey((key)message);
		}
		else if (~llListFindList(gDetectedNames, (list)message))
		{
			llOwnerSay("Hooking to name...");
			teleportToKey(llList2Key(gDetectedKeys, llListFindList(gDetectedNames, (list)message)));
		}
		llSetTimerEvent(60);
	}

	touch_start(integer total_number)
	{
		gListenHandle = llListen(gDialogChannel, "", gOwnerKey, "");
		llDialog(gOwnerKey, "\nPick action.", ["-Avatar-", "-Object-", "-UUID-", "-Up-"], gDialogChannel);
		llSetTimerEvent(60);
	}

	timer()
	{
		llListenRemove(gListenHandle);
		llSetTimerEvent(0);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	attach(key avatarKey)
	{
		if (avatarKey)
		{
			llRequestPermissions(avatarKey, PERMISSION_TAKE_CONTROLS);
		}
	}

	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_TAKE_CONTROLS)
		{
			llTakeControls(1024, TRUE, TRUE);
		}
	}

	sensor(integer detected)
	{
		gDetectedKeys = [];
		gDetectedNames = [];
		integer amount = 1;
		string dialogText = "";
		while (detected-- && amount <= 12)
		{
			gDetectedKeys = gDetectedKeys + llDetectedKey(detected);
			gDetectedNames = gDetectedNames + (string)amount;
			dialogText = dialogText + "\n" + (string)amount + ") " + llDetectedName(detected);
			++amount;
		}
		llDialog(gOwnerKey, dialogText, gDetectedNames, gDialogChannel);
		llSetTimerEvent(60);
	}

	no_sensor()
	{
		llOwnerSay("Nothing in 96m range.");
		llSetTimerEvent(2);
	}

}