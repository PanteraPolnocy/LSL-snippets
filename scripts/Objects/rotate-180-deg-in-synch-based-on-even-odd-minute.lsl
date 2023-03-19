// Written by PanteraPolnocy

integer gTurnState;
rotation gStartingRot;
rotation gSecondRot;

default
{

    state_entry()
    {
        gStartingRot = llGetRot();
        gSecondRot = llEuler2Rot(((llRot2Euler(gStartingRot) * RAD_TO_DEG) + <0, 0, 180>) * DEG_TO_RAD);
        llSetTimerEvent(0.3);
        llSetMemoryLimit(llGetUsedMemory() + 2048);
    }

    timer()
    {
        integer currentMinute = llList2Integer(llParseString2List(llGetTimestamp(), ["-", ":"], ["T"]), 5);
        if (currentMinute % 2 == 0)
        {
            if (gTurnState != currentMinute)
            {
                gTurnState = currentMinute;
                llSetRot(gStartingRot);
            }
        }
        else
        {
            if (gTurnState != currentMinute)
            {
                gTurnState = currentMinute;
                llSetRot(gSecondRot);
            }
        }
    }

    on_rez(integer sp)
    {
        llResetScript();
    }

}
