// Flashlight and light generator device, compatible with Nanite Systems' Light Bus protocol
// Tested with ARES 0.5.3 / NS-112 AIDE (March 2025)
// Written by PanteraPolnocy

// This project is an independent creation and is not officially affiliated with Nanite Systems.
// While it is designed to interface with NS devices, it is neither produced nor endorsed by Nanite Systems.
// All trademarks and product names belong to their respective owners.

string gVersion = "1.1.9";

// Device configuration below, feel free to play with these

integer gFullBrightWhenFullPower = TRUE; // TRUE / FALSE
integer gFullBrightWhenDisabled = FALSE; // TRUE / FALSE
float gGlowWhenFullPower = 1.0; // 0.0 - 1.0
float gGlowWhenDisabled = 0.0; // 0.0 - 1.0
float gLightRadiusWhenFullPower = 15.0; // 0.1 - 20.0
string gLightProjectorTexture = "b2877a04-54e8-46c6-214e-65ad6ed0ef37"; // NULL_KEY or texture UUID

string gNS_DeviceName = "brightinator"; // One-word mnemonic
integer gNS_PowerDrawWhenFullPower = 60; // In Watts
string gNS_IconTexture = "ea574d21-e7f9-7c65-8b30-b1edc0909633"; // Texture UUID; Visible in ARES HUD
vector gNS_Color = ZERO_VECTOR; // Light color; if ZERO_VECTOR here, ask Nanite OS for primary color; If not ZERO_VECTOR, use this value instead

// Internal variables below, filled in runtime
// DO NOT MODIFY

string gLightType = "Solid";
string gLastLightType;
integer gStrobeSwitch;
integer gAllowDynamicColorSwapping;

float gSelectedDevicePowerLevel;
integer gDeviceIsEnabled;
integer gDialogChannel;
integer gListenHandle;
key gOwner;

key gNS_DeviceRegisteredWith = NULL_KEY;
integer gNS_LightBusChannel;
integer gNS_SystemPowerChargePresent = -1;
float gNS_SoundVolume;
float gNS_SystemPowerLevel = -1;
string gNS_LastSystemState;
string gNS_SoundSample;

updateLight()
{
	if (gNS_LastSystemState == "on" && gNS_DeviceRegisteredWith != NULL_KEY && gDeviceIsEnabled && gSelectedDevicePowerLevel > 0 && gNS_SystemPowerLevel > 0)
	{

		if (gLightType != gLastLightType)
		{
			gLastLightType = gLightType;
			if (gLightType == "Solid") {llSetTimerEvent(0.0);}
			else if (gLightType == "Slow strobe") {llSetTimerEvent(2.0);}
			else if (gLightType == "Fast strobe") {llSetTimerEvent(0.5);}
		}

		integer lightOn = TRUE;
		if (gLightType != "Solid")
		{
			lightOn = gStrobeSwitch;
		}

		if (lightOn)
		{
			lightBus("load " + gNS_DeviceName + " drainpower " + (string)llRound(gNS_PowerDrawWhenFullPower * gSelectedDevicePowerLevel));
			llSetLinkPrimitiveParamsFast(LINK_THIS, [
				PRIM_FULLBRIGHT, ALL_SIDES, gFullBrightWhenFullPower, PRIM_POINT_LIGHT, TRUE, gNS_Color, 1.0, (gLightRadiusWhenFullPower * gSelectedDevicePowerLevel), 0.0,
				PRIM_PROJECTOR, gLightProjectorTexture, 1.3, 0.0, 0.0,
				PRIM_GLOW, ALL_SIDES, (gGlowWhenFullPower * gSelectedDevicePowerLevel)
			]);
		}
		else
		{
			switchOffLight();
		}

	}
	else
	{
		llSetTimerEvent(0.0);
		gLastLightType = "";
		switchOffLight();
	}
}

switchOffLight()
{
	if (gNS_DeviceRegisteredWith != NULL_KEY)
	{
		lightBus("load " + gNS_DeviceName + " drainpower 0");
	}
	llSetLinkPrimitiveParamsFast(LINK_THIS, [
		PRIM_FULLBRIGHT, ALL_SIDES, gFullBrightWhenDisabled, PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0.0, 0.0, 0.0,
		PRIM_GLOW, ALL_SIDES, gGlowWhenDisabled
	]);
}

lightBus(string message)
{
	key sendTo = gNS_DeviceRegisteredWith;
	if (sendTo == NULL_KEY)
	{
		sendTo = gOwner;
	}
	llRegionSayTo(sendTo, gNS_LightBusChannel, message);
}

toUser(key user, string message)
{
	llRegionSayTo(user, 0, message);
}

string getPowerDraw()
{
	return (string)llRound(gDeviceIsEnabled * gNS_PowerDrawWhenFullPower * gSelectedDevicePowerLevel) + " W / " + (string)gNS_PowerDrawWhenFullPower + " W (" + (string)llRound(gDeviceIsEnabled * gSelectedDevicePowerLevel * 100) + "%)";
}

openDialogMenu(key answerTo)
{
	gListenHandle = llListen(gDialogChannel, "", answerTo, "");
	llDialog(answerTo, "\n'" + gNS_DeviceName + "' module settings.\n Enabled: " + llList2String(["NO", "YES"], gDeviceIsEnabled) + " | " + getPowerDraw() + " | " + gLightType, ["Power: 100%", "Power: 50%", "Power: 25%", "Solid", "Slow strobe", "Fast strobe", "DISABLED", "ENABLED", "[CANCEL]"], gDialogChannel);
	setTimerEvent2(60);
}

stopListener()
{
	setTimerEvent2(0);
	llListenRemove(gListenHandle);
}

// Using no_sensor() as second llSetTimerEvent()
setTimerEvent2(float time)
{
	if (time <= 0)
	{
		llSensorRemove();
	}
	else
	{
		llSensorRepeat("cake is a lie", NULL_KEY, AGENT_BY_LEGACY_NAME, 0.001, 0.001, time);
	}
}

default
{

	state_entry()
	{
		updateLight();
		gOwner = llGetOwner();
		gDialogChannel = (integer)(llFrand(-10000000)-10000000);
		gNS_LightBusChannel = 105 - (integer)("0x" + llGetSubString(gOwner, 29, 35));
		if (gNS_Color == ZERO_VECTOR)
		{
			gAllowDynamicColorSwapping = TRUE;
		}
		llListen(gNS_LightBusChannel, "", NULL_KEY, "");
		lightBus("add " + gNS_DeviceName + " " + gVersion);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	attach(key id)
	{
		if (NULL_KEY)
		{
			if (gNS_DeviceRegisteredWith != NULL_KEY)
			{
				lightBus("load " + gNS_DeviceName + " drainpower 0");
				lightBus("remove " + gNS_DeviceName);
			}
		}
	}

	timer()
	{
		gStrobeSwitch = !gStrobeSwitch;
		updateLight();
	}

	no_sensor()
	{
		stopListener();
	}

	listen(integer channel, string name, key id, string message)
	{
		if (channel == gDialogChannel)
		{

			stopListener();
			if (gNS_DeviceRegisteredWith == NULL_KEY || message == "[CANCEL]")
			{
				return;
			}

			if (gNS_SoundVolume > 0 && gNS_SoundSample != "")
			{
				llPlaySound(gNS_SoundSample, gNS_SoundVolume);
			}

			id = llGetOwnerKey(id);
			if (gNS_SystemPowerLevel > 0)
			{
				toUser(id, "[" + gNS_DeviceName + "] " + message);
				if (message == "ENABLED")
				{
					gDeviceIsEnabled = TRUE;
					if (gSelectedDevicePowerLevel == 0.0)
					{
						gSelectedDevicePowerLevel = 1.0;
					}
				}
				else if (message == "DISABLED") {gDeviceIsEnabled = FALSE;}
				else if (message == "Power: 25%") {gSelectedDevicePowerLevel = 0.25;}
				else if (message == "Power: 50%") {gSelectedDevicePowerLevel = 0.5;}
				else if (message == "Power: 100%") {gSelectedDevicePowerLevel = 1.0;}
				else if (message == "Solid" || message == "Slow strobe" || message == "Fast strobe") {gLightType = message;}
				// --- Does not seem to be present in ARES yet: '[_hardware] unimplemented: conf-set'
				// lightBus("conf-set " + gNS_DeviceName + ".type " + gLightType + "\n" + gNS_DeviceName + ".power " + (string)gSelectedDevicePowerLevel);
				updateLight();
				openDialogMenu(id);
			}
			else
			{
				toUser(id, "Not enough power to operate '" + gNS_DeviceName + "'.");
			}

		}
		else if (llGetOwnerKey(id) == gOwner)
		{
			list commandParts = llParseStringKeepNulls(message, [" "], []);
			string command = llList2String(commandParts, 0);
			if (command == "power")
			{
				gNS_SystemPowerLevel = llList2Float(commandParts, 1);
				integer currentChargeState = llCeil(gNS_SystemPowerLevel);
				if (currentChargeState != gNS_SystemPowerChargePresent)
				{
					gNS_SystemPowerChargePresent = currentChargeState;
					updateLight();
				}
			}
			else if (command == "on")
			{
				if (gNS_LastSystemState != "on")
				{
					gNS_LastSystemState = "on";
					updateLight();
				}
			}
			else if (command == "off")
			{
				if (gNS_LastSystemState != "off")
				{
					gNS_LastSystemState = "off";
					updateLight();
				}
			}
			else if (command == "bolts")
			{
				string bolts = llList2String(commandParts, 1);
				if (bolts == "on")
				{
					llOwnerSay("@detach=n");
				}
				else if (bolts == "off")
				{
					llOwnerSay("@detach=y");
				}
			}
			else if (command == "add-confirm")
			{
				gNS_DeviceRegisteredWith = id;
				updateLight();
				lightBus("icon " + gNS_IconTexture);
				lightBus("connected " + gNS_DeviceName);
				lightBus("power-q");
				lightBus("conf-get interface.sound.act\ninterface.sound.volume\n" + gNS_DeviceName + ".type\n" + gNS_DeviceName + ".power");
				if (gAllowDynamicColorSwapping)
				{
					lightBus("color-q");
				}
			}
			else if (command == "add-fail" || command == "remove" || command == "remove-confirm")
			{
				gNS_DeviceRegisteredWith = NULL_KEY;
				gDeviceIsEnabled = FALSE;
				lightBus("disconnected " + gNS_DeviceName);
				updateLight();
			}
			else if (command == "probe")
			{
				gNS_DeviceRegisteredWith = NULL_KEY;
				lightBus("add " + gNS_DeviceName + " " + gVersion);
			}
			else if (command == "color")
			{
				if (gAllowDynamicColorSwapping)
				{
					gNS_Color = <llList2Float(commandParts, 1), llList2Float(commandParts, 2), llList2Float(commandParts, 3)>;
				}
			}
			else if (command == "conf")
			{
				list confs = llParseStringKeepNulls(llGetSubString(message, 5, -1), ["\n"], []);
				integer confsLength = llGetListLength(confs);
				integer i;
				while (i < confsLength)
				{
					string currentRow = llStringTrim(llList2String(confs, i), STRING_TRIM);
					string confName = llStringTrim(llGetSubString(currentRow, 0, llSubStringIndex(currentRow, " ")), STRING_TRIM);
					string confValue = llStringTrim(llGetSubString(currentRow, llSubStringIndex(currentRow, " "), -1), STRING_TRIM);
					if (confValue != "﷐" && llStringLength(confValue) > 0)
					{
						if (confName == "interface.sound.act") {gNS_SoundSample = confValue;}
						else if (confName == "interface.sound.volume") {gNS_SoundVolume = (float)confValue;}
						else if (confName == gNS_DeviceName + ".type") {gLightType = confValue;}
						else if (confName == gNS_DeviceName + ".power") {gSelectedDevicePowerLevel = (float)confValue;}
					}
					++i;
				}
			}
			else if (command == "icon-q")
			{
				lightBus("icon " + gNS_IconTexture);
			}
			else if (command == "peek" || command == "poke")
			{
				key answerTo = llList2Key(commandParts, 1);
				if (gNS_LastSystemState != "on" || gNS_DeviceRegisteredWith == NULL_KEY)
				{
					toUser(answerTo, "No power supplied, cannot access '" + gNS_DeviceName + "'");
				}
				else if (command == "peek")
				{
					toUser(answerTo,
						"\n========\n'" + gNS_DeviceName + "' module status:" +
						"\nCurrently enabled: " + llList2String(["NO", "YES"], gDeviceIsEnabled) +
						"\nPower draw: " + getPowerDraw() +
						"\nLight type: " + gLightType +
						"\nLight color: " + (string)gNS_Color +
						"\nFirmware version: " + gVersion + "\n========"
					);
				}
				else
				{
					openDialogMenu(answerTo);
				}
			}
		}
	}

}