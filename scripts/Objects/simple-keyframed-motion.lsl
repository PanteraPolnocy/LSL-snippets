// Written by PanteraPolnocy

default
{
	state_entry()
	{
		llSetAlpha(0, ALL_SIDES); // Makes prim invisible
		llSetLinkPrimitiveParamsFast(LINK_THIS, [
			PRIM_TEXT, "Meow", <1, 1, 1>, 1, // Set text contents, color and alpha here
			PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX,
			PRIM_PHANTOM, TRUE,
			PRIM_PHYSICS, FALSE
		]);
		llSleep(2); // Small delay just to make sure that physical shape was applied
		llSetKeyframedMotion(
			[<0.0, 0.0, 0.5>, 5, <0.0, 0.0, -0.5>, 5],
			[KFM_DATA, KFM_TRANSLATION, KFM_MODE, KFM_PING_PONG]
		);
		llSetMemoryLimit(llGetUsedMemory() + 1024);
	}
}
