// Nanite Systems light bus protocol flashlight / light generator device
// Tested with ARES 0.5.3
// Written by PanteraPolnocy

string gVersion = "1.0.4";

// Device configuration below, feel free to play with these

integer gFullBrightWhenFullPower = TRUE; // TRUE / FALSE
integer gFullBrightWhenDisabled = FALSE; // TRUE / FALSE
float gGlowWhenFullPower = 1.0; // 0.0 - 1.0
float gGlowWhenDisabled = 0.0; // 0.0 - 1.0
float gLightRadiusWhenFullPower = 15.0; // 0.1 - 20.0
string gProjectorTexture = "b2877a04-54e8-46c6-214e-65ad6ed0ef37"; // NULL_KEY or texture UUID

string gNS_DeviceName = "brightinator"; // One-word mnemonic
integer gNS_PowerDrainWhenFullPower = 60; // In Watts
string gNS_IconTexture = "ea574d21-e7f9-7c65-8b30-b1edc0909633"; // Texture UUID
vector gNS_Color = ZERO_VECTOR; // Light color; if ZERO_VECTOR here, ask Nanite OS for primary color; If not ZERO_VECTOR, use this value instead

// Internal variables below, filled in runtime
// DO NOT MODIFY

float gSelectedDevicePowerLevel;
integer gDialogChannel;
integer gListenHandle;
key gOwner;

integer gNS_DeviceRegistered;
integer gNS_LightBusChannel;
integer gNS_SystemIsOn;
float gNS_SystemPowerLevel;

updateLight()
{
	if (gNS_SystemIsOn && gNS_DeviceRegistered && gSelectedDevicePowerLevel > 0 && gNS_SystemPowerLevel > 0)
	{
		lightBus("load " + gNS_DeviceName + " drainpower " + (string)llRound(gNS_PowerDrainWhenFullPower * gSelectedDevicePowerLevel));
		llSetLinkPrimitiveParamsFast(LINK_THIS, [
			PRIM_FULLBRIGHT, ALL_SIDES, gFullBrightWhenFullPower, PRIM_POINT_LIGHT, TRUE, gNS_Color, 1.0, (gLightRadiusWhenFullPower * gSelectedDevicePowerLevel), 0.0,
			PRIM_PROJECTOR, gProjectorTexture, 1.3, 0.0, 0.0,
			PRIM_GLOW, ALL_SIDES, (gGlowWhenFullPower * gSelectedDevicePowerLevel)
		]);
	}
	else
	{
		if (gNS_DeviceRegistered)
		{
			lightBus("load " + gNS_DeviceName + " drainpower 0");
		}
		llSetLinkPrimitiveParamsFast(LINK_THIS, [
			PRIM_FULLBRIGHT, ALL_SIDES, gFullBrightWhenDisabled, PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0.0, 0.0, 0.0,
			PRIM_GLOW, ALL_SIDES, gGlowWhenDisabled
		]);
	}
}

lightBus(string message)
{
	llRegionSayTo(gOwner, gNS_LightBusChannel, message);
}

toUser(key user, string message)
{
	llRegionSayTo(user, 0, message);
}

stopListener()
{
	llSetTimerEvent(0);
	llListenRemove(gListenHandle);
}

default
{

	state_entry()
	{
		updateLight();
		gOwner = llGetOwner();
		gDialogChannel = (integer)(llFrand(-10000000)-10000000);
		gNS_LightBusChannel = 105 - (integer)("0x" + llGetSubString(gOwner, 29, 35));
		llListen(gNS_LightBusChannel, "", NULL_KEY, "");
		lightBus("add " + gNS_DeviceName + " " + gVersion);
		llSetMemoryLimit(llGetUsedMemory() + 10240);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	attach(key id)
	{
		if (NULL_KEY)
		{
			if (gNS_DeviceRegistered)
			{
				lightBus("load " + gNS_DeviceName + " drainpower 0");
				lightBus("remove " + gNS_DeviceName);
			}
		}
	}

	timer()
	{
		stopListener();
	}

	listen(integer channel, string name, key id, string message)
	{
		id = llGetOwnerKey(id);
		if (id == gOwner)
		{

			if (channel == gDialogChannel)
			{
				if (!gNS_DeviceRegistered)
				{
					return;
				}
				stopListener();
				toUser(id, "[" + gNS_DeviceName + "] " + message);
				if (message == "Disabled" || (gNS_SystemPowerLevel > 0 && message == "Power: 50%") || (gNS_SystemPowerLevel > 0 && message == "Power: 100%"))
				{
					if (message == "Disabled") {gSelectedDevicePowerLevel = 0;}
					else if (message == "Power: 50%") {gSelectedDevicePowerLevel = 0.5;}
					else if (message == "Power: 100%") {gSelectedDevicePowerLevel = 1.0;}
					updateLight();
				}
				else
				{
					toUser(id, "Not enough power to enable '" + gNS_DeviceName + "'.");
				}
				return;
			}

			list commandParts = llParseStringKeepNulls(message, [" "], []);
			string command = llList2String(commandParts, 0);

			if (command == "power")
			{
				gNS_SystemPowerLevel = llList2Float(commandParts, 1);
				if (gNS_SystemPowerLevel <= 0)
				{
					updateLight();
				}
			}
			else if (command == "on")
			{
				gNS_SystemIsOn = TRUE;
				updateLight();
			}
			else if (command == "off")
			{
				gNS_SystemIsOn = FALSE;
				updateLight();
			}
			else if (command == "add-confirm")
			{
				gNS_DeviceRegistered = TRUE;
				lightBus("icon " + gNS_IconTexture);
				lightBus("color-q");
				lightBus("power-q");
				updateLight();
			}
			else if (command == "remove-confirm" || command == "add-fail" || command == "remove")
			{
				gNS_DeviceRegistered = FALSE;
				gSelectedDevicePowerLevel = 0;
				updateLight();
				if (command == "remove")
				{
					lightBus("remove " + gNS_DeviceName);
					if (llGetAttached())
					{
						llRequestPermissions(gOwner, PERMISSION_ATTACH);
					}
				}
			}
			else if (command == "probe")
			{
				gNS_DeviceRegistered = FALSE;
				lightBus("add " + gNS_DeviceName + " " + gVersion);
			}
			else if (command == "color")
			{
				if (gNS_Color == ZERO_VECTOR)
				{
					gNS_Color = <llList2Float(commandParts, 1), llList2Float(commandParts, 2), llList2Float(commandParts, 3)>;
				}
			}
			else if (command == "icon-q")
			{
				lightBus("icon " + gNS_IconTexture);
			}
			else if (command == "peek" || command == "poke")
			{
				key answerTo = llList2Key(commandParts, 1);
				if (!gNS_SystemIsOn)
				{
					toUser(answerTo, "System is offline, cannot access '" + gNS_DeviceName + "'");
					return;
				}
				if (command == "peek")
				{
					toUser(answerTo,
						"\n========\n'" + gNS_DeviceName + "' module status:" +
						"\nCurrently enabled: " + llList2String(["NO", "YES"], (integer)gSelectedDevicePowerLevel) +
						"\nPower drain: " + (string)llRound(gNS_PowerDrainWhenFullPower * gSelectedDevicePowerLevel) + " W / " + (string)gNS_PowerDrainWhenFullPower + " W (" + (string)llRound(gSelectedDevicePowerLevel * 100) + "%)" +
						"\nLight color: " + (string)gNS_Color +
						"\nFirmware version: " + gVersion + "\n========"
					);
				}
				else
				{
					gListenHandle = llListen(gDialogChannel, "", answerTo, "");
					llDialog(answerTo, "\n'" + gNS_DeviceName + "' module settings.", ["Disabled", "Power: 100%", "Power: 50%"], gDialogChannel);
					llSetTimerEvent(60);
				}
			}

		}
	}

	run_time_permissions(integer perm)
	{
		if (perm & PERMISSION_ATTACH)
		{
			llDetachFromAvatar();
		}
	}

}
