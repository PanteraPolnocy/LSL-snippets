// Written by PanteraPolnocy
// Older script

// --- Config start

float LightRadiusInMetres = 10.0;
float LightIntensity = 1.0;
float LightFalloff = 1.0;
float GlowLevel = 0.75;

// --- Config end

integer dayTime = 3;
default {
	on_rez(integer p) {
		llResetScript();
	}
	state_entry() {
		llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, 0, PRIM_FULLBRIGHT, ALL_SIDES, FALSE]);
		llSetTimerEvent(300);
		llSetMemoryLimit(llGetUsedMemory() + 2048);
	}
	timer() {
		vector s = llGetSunDirection();
		if(s.z < 0.0) {
			if(dayTime != 2) {
				dayTime = 2;
				llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1, 1, 1>, 1.0, PRIM_FULLBRIGHT, ALL_SIDES, TRUE, PRIM_GLOW, ALL_SIDES, GlowLevel, PRIM_POINT_LIGHT, TRUE, <1, 1, 1>, LightIntensity, LightRadiusInMetres, LightFalloff]);
			}
		}
		if(s.z > 0.0) {
			if(dayTime != 1) {
				dayTime = 1;
				llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1, 1, 1>, 1.0, PRIM_FULLBRIGHT, ALL_SIDES, FALSE, PRIM_GLOW, ALL_SIDES, 0, PRIM_POINT_LIGHT, FALSE, <1, 1, 1>, 0, 0, 0]);
			}
		}
	}
}