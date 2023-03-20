// OpenAI's ChatGPT integration for LSL
// Written by PanteraPolnocy, March 2023
// Version 2.5.1

// You're responsible for how your OpenAI account will be used!
// Set script to "everyone" or "same group" on your own risk. Mandatory reading:
// https://platform.openai.com/docs/usage-policies
// https://openai.com/pricing

// Place your API key here
// https://platform.openai.com/account/api-keys
string gChatGptApiKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// ----------------------------------

// Defaults, do NOT change them here - use dialog menu instead!
integer gBodyMaxLength = 16384;
string gListenMode = "Owner";
string gAnswerIn = "Nearby chat";
integer gHovertext = TRUE;
list gOpenAiModels = [

	"ModelName", "Davinci (chat)",
	"Endpoint", "/v1/completions",
	"Items", 6,
	"model", "text-davinci-003",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "GPT-4 (chat)",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-4",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "3.5 Turbo (chat)",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-3.5-turbo",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "DALL-E (images)",
	"Endpoint", "/v1/images/generations",
	"Items", 2,
	"n", 1,
	"size", "1024x1024"

];

// Set in runtime
integer gEnabled;
integer gListenHandle;
integer gDialogChannel;
integer gDialogHandle;
integer gChatIsLocked;
integer gSimpleAnswers;
string gCurrentEndpoint;
string gCurrentModelName;
list gCurrentModelData;
list gModelsList;
key gAnswerToAvatar;
key gHTTPRequestId;
key gOwnerKey;

// Functions

setListener()
{
	key listenKey = NULL_KEY;
	if (gListenMode == "Owner")
	{
		listenKey = gOwnerKey;
	}
	gListenHandle = llListen(PUBLIC_CHANNEL, "", listenKey, "");
	llListenControl(gListenHandle, gEnabled);
	llSetText(gCurrentModelName + llList2String(["", "\nSimple answers"], gSimpleAnswers) + "\n" + llList2String(["Disabled", "Enabled"], gEnabled), <1, 1, 1>, gHovertext * 0.6);
}

setModel(string modelName)
{
	integer modelPosition = llListFindList(gOpenAiModels, (list)modelName);
	gCurrentEndpoint = llList2String(gOpenAiModels, modelPosition + 2);
	gCurrentModelData = llList2List(gOpenAiModels, modelPosition + 5, modelPosition + 4 + llList2Integer(gOpenAiModels, modelPosition + 4) * 2);
	gCurrentModelName = modelName;
	llOwnerSay("Model selected: " + modelName);
}

startDialog(key id, string text, list buttons)
{
	gDialogHandle = llListen(gDialogChannel, "", id, "");
	llDialog(id, "\n" + text, buttons, gDialogChannel);
	llSetTimerEvent(60);
}

stopDialog()
{
	llSetTimerEvent(0);
	llListenRemove(gDialogHandle);
}

setChatLock(integer enable)
{
	gChatIsLocked = enable;
	if (enable)
	{
		// Chat lock timeout (10 seconds)
		llSensorRepeat("cake is a lie", NULL_KEY, AGENT_BY_LEGACY_NAME, 0.001, 0.001, 10);
	}
	else
	{
		llSensorRemove();
	}
}

// Script body

default
{

	state_entry()
	{

		llOwnerSay("Starting up...");
		gOwnerKey = llGetOwner();
		gDialogChannel = (integer)(llFrand(-10000000)-10000000);

		integer modelsLength = llGetListLength(gOpenAiModels);
		integer i;
		while (i < modelsLength)
		{
			string currentItem = llList2String(gOpenAiModels, i);
			if (currentItem == "ModelName")
			{
				gModelsList = gModelsList + llList2String(gOpenAiModels, i + 1);
			}
			++i;
		}

		if (llGetMemoryLimit() <= 16384)
		{
			gBodyMaxLength = 4096;
			llOwnerSay("WARNING: You're using LSO VM. Maximum response body will be limited. Please compile script as Mono.");
		}

		setModel(llList2String(gModelsList, 0));
		stopDialog();
		setListener();
		setChatLock(FALSE);
		llOwnerSay("Ready. Touch me to set options or enable / disable.");

	}

	touch_start(integer nd)
	{
		key toucherKey = llDetectedKey(0);
		if (toucherKey == gOwnerKey)
		{
			startDialog(toucherKey, "Current state: " + llList2String(["Disabled", "Enabled"], gEnabled) + "\nCurrent model: " + gCurrentModelName + "\nListen mode: " + gListenMode + "\nAnswering in: " + gAnswerIn + "\nSimple answers mode: " + llList2String(["Disabled", "Enabled"], gSimpleAnswers), ["Simple mode", "Listen to", "Answer in", "Hovertext", "Select model", "ON / OFF"]);
		}
	}

	listen(integer channel, string name, key id, string message)
	{

		if (channel == gDialogChannel)
		{
			stopDialog();
			if (message == "ON / OFF")
			{
				gEnabled = !gEnabled;
				setListener();
				llOwnerSay("Listener " + llList2String(["disabled", "enabled"], gEnabled) + ".");
			}
			else if (message == "Hovertext")
			{
				gHovertext = !gHovertext;
				setListener();
				llOwnerSay("Hovertext " + llList2String(["disabled", "enabled"], gHovertext) + ".");
			}
			else if (message == "Simple mode")
			{
				gSimpleAnswers = !gSimpleAnswers;
				setListener();
				llOwnerSay("Simple answers mode " + llList2String(["disabled", "enabled"], gSimpleAnswers) + ".");
			}
			else if (message == "Owner" || message == "Same group" || message == "Everyone")
			{
				gListenMode = message;
				setListener();
				llOwnerSay("Listen mode set to: " + message);
			}
			else if (message == "Nearby chat" || message == "Privately")
			{
				gAnswerIn = message;
				setListener();
				llOwnerSay("Answering in: " + message);
			}
			else if (message == "Select model")
			{
				startDialog(id, "Select the OpenAI model.\nCurrent one: " + gCurrentModelName, gModelsList);
			}
			else if (message == "Listen to")
			{
				startDialog(id, "Select listen mode.\nCurrent one: " + gListenMode, ["Owner", "Same group", "Everyone"]);
			}
			else if (message == "Answer in")
			{
				startDialog(id, "Select where to send responses.\nCurrently: " + gAnswerIn, ["Nearby chat", "Privately"]);
			}
			else if (~llListFindList(gModelsList, (list)message))
			{
				setModel(message);
				setListener();
			}
			return;
		}

		id = llGetOwnerKey(id);
		if (gChatIsLocked || (gListenMode == "Owner" && id != gOwnerKey) || llGetAgentSize(id) == ZERO_VECTOR || llVecDist(llGetPos(), llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0)) > 20 || (gListenMode == "Same group" && !llSameGroup(id)))
		{
			return;
		}

		setChatLock(TRUE);
		gAnswerToAvatar = id;

		message = llStringTrim(message, STRING_TRIM);
		if (gCurrentModelName == "GPT-4 (chat)" || gCurrentModelName == "3.5 Turbo (chat)" || gCurrentModelName == "Davinci (chat)")
		{
			message = "Be as helpful as possible. UTC now: " + llGetTimestamp() + ". Person sending this query to you: \"" + llGetUsername(id) + "\". Reply to message: " + message;
			if (gSimpleAnswers)
			{
				message = "Answer in a way a 5-year-old would understand. " + message;
			}
		}
		else if (gCurrentModelName == "DALL-E (images)")
		{
			if (gAnswerIn == "Nearby chat")
			{
				llSay(0, "Query received, please be patient...");
			}
			else
			{
				llRegionSayTo(gAnswerToAvatar, 0, "Query received, please be patient...");
			}
		}

		list promptAdditions;
		if (gCurrentModelName == "GPT-4 (chat)" || gCurrentModelName == "3.5 Turbo (chat)")
		{
			promptAdditions = ["user", (string)id, "messages", "[" + llList2Json(JSON_OBJECT, ["role", "user", "content", message]) + "]"];
		}
		else
		{
			promptAdditions = ["user", (string)id, "prompt", message];
		}

		gHTTPRequestId = llHTTPRequest("https://api.openai.com" + gCurrentEndpoint, [
			HTTP_MIMETYPE, "application/json",
			HTTP_METHOD, "POST",
			HTTP_BODY_MAXLENGTH, gBodyMaxLength,
			HTTP_ACCEPT, "application/json",
			HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + gChatGptApiKey
		], llList2Json(JSON_OBJECT, llListInsertList(gCurrentModelData, promptAdditions, 0)));

	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		if (gHTTPRequestId == request_id)
		{

			// Davinci
			string result = llJsonGetValue(body, ["choices", 0, "text"]);

			// GPT-4, GPT 3.5 Turbo
			if (result == JSON_INVALID || result == JSON_NULL)
			{
				result = llJsonGetValue(body, ["choices", 0, "message", "content"]);
			}

			// DALL-E
			if (result == JSON_INVALID || result == JSON_NULL)
			{
				result = llJsonGetValue(body, ["data", 0, "url"]);
			}

			if (result == JSON_INVALID || result == JSON_NULL || llStringTrim(result, STRING_TRIM) == "")
			{
				llSay(0, "Something went wrong, please try again in a moment.");
				llOwnerSay("[SERVER MESSAGE] [HTTP STATUS " + (string)status + "] " + body);
				setChatLock(FALSE);
				return;
			}

			result = "([https://platform.openai.com/docs/usage-policies AI]) " + llStringTrim(result, STRING_TRIM);
			if (gAnswerIn == "Nearby chat")
			{
				llSay(0, result);
			}
			else
			{
				llRegionSayTo(gAnswerToAvatar, 0, result);
			}

			setChatLock(FALSE);

		}
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	timer()
	{
		stopDialog();
	}

	no_sensor()
	{
		setChatLock(FALSE);
	}

	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			llResetScript();
		}
	}

}