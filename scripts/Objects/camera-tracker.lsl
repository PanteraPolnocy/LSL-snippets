// Written by PanteraPolnocy

default
{

    on_rez(integer a)
    {
        llResetScript();
    }

    state_entry()
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHANTOM, TRUE]);
        llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA);
    }

    run_time_permissions(integer perms)
    {
        if (perms == PERMISSION_TRACK_CAMERA)
        {
            llOwnerSay("Camera tracking started...");
            llSetTimerEvent(0.5);
        }
        else
        {
            llOwnerSay("I can't work without permission to track your camera. Re-rezz me and click on 'accept'.");
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_REGION_START) 
        {
            llDie(); // Got lost? Delete itself.
        }
        else if (change & CHANGED_OWNER)
        {
            llResetScript(); // Re-request camera tracking perms
        }
    }

    timer()
    {
        rotation currentCamRot = llGetCameraRot();
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POSITION, llGetCameraPos() + <2,0,0> * currentCamRot, PRIM_ROTATION, currentCamRot]);
    }

}