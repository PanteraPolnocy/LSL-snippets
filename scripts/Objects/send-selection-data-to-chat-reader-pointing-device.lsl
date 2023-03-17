// Written by PanteraPolnocy

key gOwner;

default
{

    state_entry()
    {
        gOwner = llGetOwner();
        llListen(9000, "", gOwner, "");
        llOwnerSay("Booted.");
        integer usedMemory = llGetUsedMemory();
        if (usedMemory < 45056)
        {
            llSetMemoryLimit(usedMemory + 20480);
        }
    }

    attach(key avatarKey)
    {
        if (avatarKey)
        {
            llRequestPermissions(avatarKey, PERMISSION_TAKE_CONTROLS);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        list tempList = llParseString2List(message, [" "], ["<", ">", ","]);
        if (llGetListLength(tempList) == 7)
        {
            if (((string)((vector)message) == (string)((vector)((string)llListInsertList(tempList, ["-"], 5)))) == FALSE)
            {
                vector tempVector = (vector)message - llGetRegionCorner();
                if (tempVector != ZERO_VECTOR && llVecDist(llList2Vector(llGetObjectDetails(gOwner, [OBJECT_POS]), 0), tempVector) < 10)
                {
                    while (llList2Vector(llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POSITION]), 0) != tempVector)
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POSITION, tempVector]);
                    }
                }
            }
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            // Take control for value that does nothing, in order to work in no-script sims
            llTakeControls(1024, TRUE, TRUE);
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

}