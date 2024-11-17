// Written by PanteraPolnocy

key gLastPersonInTransit;

teleportUser(key id)
{
	if (id != gLastPersonInTransit && llGetAgentSize(id) != ZERO_VECTOR)
	{
		gLastPersonInTransit = id;
		llRequestExperiencePermissions(id, "");
	}
}

default
{

	state_entry()
	{
		llSetMemoryLimit(llGetUsedMemory() + 20480);
	}

	changed(integer change)
	{
		if (change & CHANGED_REGION_START) 
		{
			llResetScript();
		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	collision_start(integer nd)
	{
		integer index = 0;
		while (index < nd)
		{
			teleportUser(llDetectedKey(index));
			++index;
		}
	}

	collision(integer nd)
	{
		integer index = 0;
		while (index < nd)
		{
			teleportUser(llDetectedKey(index));
			++index;
		}
	}

	experience_permissions(key agent_id)
	{
		llTeleportAgent(agent_id, llGetInventoryName(INVENTORY_LANDMARK, 0), ZERO_VECTOR, ZERO_VECTOR);
	}

}