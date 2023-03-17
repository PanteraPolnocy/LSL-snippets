// Written by PanteraPolnocy

integer gRaised = 0;

default {
    
    on_rez(integer sp) {
        llResetScript();   
    }

    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0, 1, 1>, 0, PRIM_PHANTOM, FALSE, PRIM_POINT_LIGHT, FALSE, <0, 1, 1>, 1, 20, 0.25, PRIM_FULLBRIGHT, ALL_SIDES, TRUE, PRIM_GLOW, ALL_SIDES, 0]);
        llSetLinkTexture(LINK_THIS, "17b1b684-3a59-c2f2-fc24-74f6bb769c52", ALL_SIDES);
        llSetLinkTextureAnim(LINK_THIS, ANIM_ON | SMOOTH | LOOP, ALL_SIDES, 1, 1, 1, 1, 15);
    }

    collision_start(integer nd) {
        if(gRaised == 0 && llGetAgentSize(llDetectedKey(0)) != ZERO_VECTOR) {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0, 1, 1>, 0.25, PRIM_POINT_LIGHT, TRUE, <0, 1, 1>, 1, 20, 0.25, PRIM_PHANTOM, TRUE]);
            llSetTimerEvent(2);
        } else {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0, 1, 1>, 0.25, PRIM_POINT_LIGHT, TRUE, <0, 1, 1>, 1, 20, 0.25, PRIM_PHANTOM, FALSE]);
            if(gRaised == 0) {
                gRaised = 1;
                llWhisper(0, "Projectile detected, raising security shields...");
            }
            llSetTimerEvent(5);
        }
    }

    timer() {
        gRaised = 0;
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <0, 1, 1>, 0, PRIM_PHANTOM, FALSE, PRIM_POINT_LIGHT, FALSE, <0, 1, 1>, 1, 20, 0.25]);
        llSetTimerEvent(0);
    }

}