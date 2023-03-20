// Written by PanteraPolnocy
// Texture and sculpt map permission checker
// Older script
// 07 Feb 2013, version 1.3

default {
	on_rez(integer sp) {
		llResetScript();
	}
	changed(integer change) {
		if (change & (CHANGED_INVENTORY | CHANGED_REGION_START | CHANGED_OWNER | CHANGED_ALLOWED_DROP)) {
			llResetScript();
		}
	}
	state_entry() {
		integer i = 0;
		integer pn = llGetNumberOfPrims()+1;
		llOwnerSay("Starting texture permission check, prim count in linkset: "+(string)(pn-1));
		while(i <= pn) {
			integer sides = llGetLinkNumberOfSides(i);
			if(sides > 0) {
				llOwnerSay("Prim with index: "+(string)i+" has sides: "+(string)sides+", checking...");
				integer x = 0;
				while(x <= sides) {
					if(llList2Key(llGetLinkPrimitiveParams(i, [PRIM_TEXTURE, x]), 1) == NULL_KEY) {
						llOwnerSay("Texture for side: "+(string)x+" is NOT okay, trying to mark as red.");
						llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, x, <1,0,0>, 1.0, PRIM_GLOW, x, 1]);
					}
					++x;
				}
				list primParams = llGetLinkPrimitiveParams(i, [PRIM_TYPE]);
				if(llList2Integer(primParams, 0) == PRIM_TYPE_SCULPT) {
					if(llList2Key(primParams, 1) == NULL_KEY) {
						llOwnerSay("Sculpt map for prim with index: "+(string)i+" is NOT okay, trying to mark as blue.");
						llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, <0,0,1>, 1.0, PRIM_GLOW, ALL_SIDES, 1]);
					}
				}
			}
			++i;
		}
		llOwnerSay("Finished.");
	}
}
