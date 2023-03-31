// OpenAI's ChatGPT integration for LSL
// Written by PanteraPolnocy, March 2023
// Version 2.6.2

// You're responsible for how your OpenAI account will be used!
// Set script to "everyone" or "same group" on your own risk. Mandatory reading:
// https://platform.openai.com/docs/usage-policies
// https://openai.com/pricing

// Place your API key here
// https://platform.openai.com/account/api-keys
string gChatGptApiKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// ----------------------------------

// Defaults, do NOT change them here - use dialog menu instead!
integer gScriptReady;
string gListenMode = "Owner";
string gAnswerIn = "Nearby chat";
integer gHovertext = TRUE;
list gOpenAiModels = [

	"ModelName", "3.5 Turbo",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-3.5-turbo",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "GPT-4",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-4",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "Davinci",
	"Endpoint", "/v1/completions",
	"Items", 6,
	"model", "text-davinci-003",
	"temperature", 0.9,
	"max_tokens", 250,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "DALL-E",
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
integer gHistoryEnabled;
string gCurrentEndpoint;
string gCurrentModelName;
list gCurrentModelData;
list gModelsList;
list gHistoryRecords;
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
	llSetText(gCurrentModelName + llList2String(["", "\nHistory enabled"], gHistoryEnabled) + llList2String(["", "\nSimple answers"], gSimpleAnswers) + "\n" + llList2String(["DISABLED", "ENABLED"], gEnabled), <1, 1, 1>, gHovertext * 0.6);
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

addToHistory(string role, string message)
{
	if (gCurrentModelName == "GPT-4" || gCurrentModelName == "3.5 Turbo")
	{
		if (!gHistoryEnabled)
		{
			gHistoryRecords = [];
		}
		gHistoryRecords = gHistoryRecords + llList2Json(JSON_OBJECT, ["role", role, "content", llGetSubString((string)llParseString2List(message, ["\\n"], []), 0, 1500)]);
		integer historyLength = llGetListLength(gHistoryRecords);
		if (historyLength > 12)
		{
			gHistoryRecords = llList2List(gHistoryRecords, historyLength - 12, historyLength);
		}
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
			llOwnerSay("WARNING: You're using LSO VM. Please compile script as Mono. Operation will not continue.");
		}
		else
		{
			setModel(llList2String(gModelsList, 0));
			stopDialog();
			setListener();
			setChatLock(FALSE);
			llOwnerSay("Ready. Touch me to set options or enable / disable.");
			gScriptReady = TRUE;
		}

	}

	touch_start(integer nd)
	{
		key toucherKey = llDetectedKey(0);
		if (toucherKey == gOwnerKey && gScriptReady)
		{
			startDialog(toucherKey,
				"Current state: " + llList2String(["DISABLED", "ENABLED"], gEnabled) +
				"\nCurrent model: " + gCurrentModelName +
				"\nHistory (3.5 Turbo and GPT-4): " + llList2String(["DISABLED", "ENABLED"], gHistoryEnabled) +
				"\nSimple answers (chats / completions): " + llList2String(["DISABLED", "ENABLED"], gSimpleAnswers) +
				"\nListening to: " + gListenMode +
				"\nAnswering in: " + gAnswerIn,
				["Simple mode", "History", "Hovertext", "Listen to", "Answer in", "Select model", "ON / OFF"]
			);
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
				llOwnerSay("Listener " + llList2String(["DISABLED", "ENABLED"], gEnabled) + ".");
			}
			else if (message == "Hovertext")
			{
				gHovertext = !gHovertext;
				setListener();
				llOwnerSay("Hovertext " + llList2String(["DISABLED", "ENABLED"], gHovertext) + ".");
			}
			else if (message == "Simple mode")
			{
				gSimpleAnswers = !gSimpleAnswers;
				setListener();
				llOwnerSay("Simple answers mode " + llList2String(["DISABLED.", "ENABLED. Please remember, that this functionality is only available with chat and completions models."], gSimpleAnswers));
			}
			else if (message == "History")
			{
				gHistoryEnabled = !gHistoryEnabled;
				setListener();
				llOwnerSay("History is now " + llList2String(["DISABLED.", "ENABLED. Please remember, that this functionality is only available with chat models (3.5 Turbo and GPT-4)."], gHistoryEnabled));
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
				startDialog(id, "Select the OpenAI model.\n \n'3.5 Turbo' and 'GPT-4' are chat models with optional history support, 'Davinci' is the text completions model, 'DALL-E' can generate image links.\n \nCurrent one: " + gCurrentModelName, gModelsList);
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
		list promptAdditions;

		if (gCurrentModelName == "GPT-4" || gCurrentModelName == "3.5 Turbo" || gCurrentModelName == "Davinci")
		{
			string messageParsed = llList2String(["", "Answer in a way a 5-year-old would understand. "], gSimpleAnswers) + "Be as helpful as possible. UTC now: " + llGetTimestamp() + ". Person sending this query to you: \"" + llGetUsername(id) + "\". Answer must be max 1024 characters.";
			if (gCurrentModelName == "Davinci")
			{
				promptAdditions = ["user", (string)id, "prompt", messageParsed + " Reply to message: " + message];
			}
			else
			{
				addToHistory("user", message);
				promptAdditions = ["user", (string)id, "messages", "[" + llDumpList2String(llList2Json(JSON_OBJECT, ["role", "system", "content", messageParsed]) + gHistoryRecords, ",") + "]"];
			}
		}
		else if (gCurrentModelName == "DALL-E")
		{
			promptAdditions = ["user", (string)id, "prompt", message];
			if (gAnswerIn == "Nearby chat")
			{
				llSay(0, "Query received, please be patient...");
			}
			else
			{
				llRegionSayTo(gAnswerToAvatar, 0, "Query received, please be patient...");
			}
		}

		gHTTPRequestId = llHTTPRequest("https://api.openai.com" + gCurrentEndpoint, [
			HTTP_MIMETYPE, "application/json",
			HTTP_METHOD, "POST",
			HTTP_BODY_MAXLENGTH, 16384,
			HTTP_ACCEPT, "application/json",
			HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + gChatGptApiKey
		], llList2Json(JSON_OBJECT, llListInsertList(gCurrentModelData, promptAdditions, 0)));

	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		if (gHTTPRequestId == request_id)
		{

			// GPT-4, GPT 3.5 Turbo
			string result = llJsonGetValue(body, ["choices", 0, "message", "content"]);

			// Davinci
			if (result == JSON_INVALID || result == JSON_NULL)
			{
				result = llJsonGetValue(body, ["choices", 0, "text"]);
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

			result = llStringTrim(result, STRING_TRIM);
			addToHistory("assistant", result);
			result = "([https://platform.openai.com/docs/usage-policies AI]) " + result;
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