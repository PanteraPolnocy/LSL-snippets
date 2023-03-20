// Written by PanteraPolnocy
// Older script

integer COMM_CHANNEL = -2312396;

bub(key avatar_key, integer isOn)
{
	if (isOn)
	{
		llParticleSystem([
			PSYS_PART_FLAGS,(0
			| PSYS_PART_EMISSIVE_MASK
			| PSYS_PART_BOUNCE_MASK
			| PSYS_PART_INTERP_COLOR_MASK
			| PSYS_PART_INTERP_SCALE_MASK
			| PSYS_PART_WIND_MASK
			| PSYS_PART_TARGET_POS_MASK
			),PSYS_SRC_TARGET_KEY,avatar_key,
			PSYS_PART_START_COLOR,<1.00000, 1.00000, 1.00000>,
			PSYS_PART_END_COLOR,<1.00000, 1.00000, 1.00000>,
			PSYS_PART_START_ALPHA,0.800000,
			PSYS_PART_END_ALPHA,0.000000,
			PSYS_PART_START_SCALE,<0.0100, 0.01000, 0.00000>,
			PSYS_PART_END_SCALE,<0.09,0.09, 0.00000>,
			PSYS_PART_MAX_AGE,1.0,
			PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.7>,
			PSYS_SRC_PATTERN,2,
			PSYS_SRC_TEXTURE,"fda6b800-b2c5-e859-5c1a-27a88457f7df",
			PSYS_SRC_BURST_RATE,0.200000,
			PSYS_SRC_BURST_PART_COUNT,28,
			PSYS_SRC_BURST_RADIUS,0.14,
			PSYS_SRC_BURST_SPEED_MIN,0.05000,
			PSYS_SRC_BURST_SPEED_MAX,0.10000,
			PSYS_SRC_MAX_AGE,0.000000,
			PSYS_SRC_OMEGA,<1.07749, 1.07749, 1.07749>,
			PSYS_SRC_ANGLE_BEGIN,0.809775*PI,
			PSYS_SRC_ANGLE_END,0.550609*PI
		]);
	}
	else
	{
		llParticleSystem([]);
	}
}

default
{

	on_rez(integer param)
	{
		llResetScript();
	}

	state_entry()
	{
		llListen(COMM_CHANNEL, "", NULL_KEY, "");
		integer usedMemory = llGetUsedMemory();
		if (usedMemory < 45056)
		{
			llSetMemoryLimit(usedMemory + 20480);
		}
	}

	sensor( integer detected )
	{
		float smallestDistance = 96.0;
		vector currentPos = llGetPos();
		key nearestPerson = NULL_KEY;
		while(detected--)
		{
			key currentPerson = llDetectedKey(detected);
			float currentDistance = llVecDist(llList2Vector(llGetObjectDetails(currentPerson, [OBJECT_POS]), 0), currentPos);
			if (currentDistance < smallestDistance)
			{
				smallestDistance = currentDistance;
				nearestPerson = currentPerson;
			}
		}
		bub(nearestPerson, TRUE);
	}

	listen(integer channel, string name, key id, string msg)
	{
		if (msg == "bub")
		{
			llSensor("", NULL_KEY, AGENT, 96.0, PI);
		}
		else if (msg == "stopbub")
		{
			bub(NULL_KEY, FALSE);
		}
	}

}