// OpenAI's ChatGPT integration for LSL
// Written by PanteraPolnocy, March 2023
// Version 2.16

// You're responsible for how your OpenAI account will be used!
// Set script to "everyone" or "same group" on your own risk. Mandatory reading:
// https://platform.openai.com/docs/usage-policies
// https://openai.com/pricing

// Place your API key here
// https://platform.openai.com/account/api-keys
string gChatGptApiKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

// ----------------------------------

// Defaults, do NOT change them here - use the dialog menu instead! Unless you know what you are doing...
string gListenMode = "Owner";
string gAnswerIn = "Nearby chat";
integer gEnabled = FALSE;
integer gHovertext = TRUE;
integer gSimpleAnswers = FALSE;
integer gHistoryEnabled = FALSE;
integer gPrefixMode = FALSE;

// Models database; First one is default
list gOpenAiModels = [

	"ModelName", "GPT-4o Mini",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-4o-mini",
	"temperature", 0.9,
	"max_tokens", 1000,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6,

	"ModelName", "GPT-4o",
	"Endpoint", "/v1/chat/completions",
	"Items", 6,
	"model", "gpt-4o",
	"temperature", 0.9,
	"max_tokens", 1000,
	"top_p", 1,
	"frequency_penalty", 0.0,
	"presence_penalty", 0.6

];

// Personalities database; First one is default
list gPersonalities = [

	"Assistant",
	"a friendly assistant, as helpful as possible",
	"default personality",

	"Data",
	"the android Data from Star Trek (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"android from Star Trek, logical",

	"Picard",
	"the Captain Jean-Luc Picard from Star Trek (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"captain from Star Trek, strong leader",

	"JARVIS",
	"the J.A.R.V.I.S. AI from Marvel (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"AI from Marvel, polite",

	"Napoleon",
	"the historical character Napoleon Bonaparte (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"military conquests, strategic thinking",

	"Einstein",
	"the historical character Albert Einstein (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"contributions to physics",

	"Socrates",
	"the historical character Socrates (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"philosopher, critical thinking",

	"Shakespeare",
	"the historical character William Shakespeare (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"renowned playwright",

	"Monroe",
	"the historical character Marilyn Monroe (use tone, manner, vocabulary that she would), answer only as she would, know all that she would",
	"iconic actress",

	"Curie",
	"the historical character Marie Curie (use tone, manner, vocabulary that she would), answer only as she would, know all that she would",
	"Marie Curie, a scientist",

	"Elvis",
	"the historical character Elvis Presley (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"beloved musician",

	"Freud",
	"the historical character Sigmund Freud (use tone, manner, vocabulary that he would), answer only as he would, know all that he would",
	"psychologist"

];

// Set in runtime
list gCurrentModelData;
list gModelsList;
list gPersonalitiesList;
list gHistoryRecords;

// Functions

setListener()
{
	string currentChatHandle = llLinksetDataRead("gptvar:chat_handle");
	if (currentChatHandle != "")
	{
		llListenRemove((integer)currentChatHandle);
	}
	if (gEnabled)
	{
		key listenKey = NULL_KEY;
		if (gListenMode == "Owner")
		{
			listenKey = llGetOwner();
		}
		llLinksetDataWrite("gptvar:chat_handle", (string)llListen(PUBLIC_CHANNEL, "", listenKey, ""));
	}
	llSetText(llLinksetDataRead("gptvar:current_personality_name") + " (" + llLinksetDataRead("gptvar:current_model_name") + ")" + llList2String(["", "\nHistory enabled"], gHistoryEnabled) + llList2String(["", "\nPrefix mode"], gPrefixMode) + llList2String(["", "\nSimple answers"], gSimpleAnswers) + "\n" + llList2String(["DISABLED", "ENABLED"], gEnabled), <1, 1, 1>, gHovertext * 0.6);
}

setModel(string modelName)
{
	list openAiModels = llJson2List(llLinksetDataRead("gptvar:openai_models"));
	integer modelPosition = llListFindList(openAiModels, (list)modelName);
	gCurrentModelData = llList2List(openAiModels, modelPosition + 5, modelPosition + 4 + llList2Integer(openAiModels, modelPosition + 4) * 2);
	llLinksetDataWrite("gptvar:current_endpoint", llList2String(openAiModels, modelPosition + 2));
	llLinksetDataWrite("gptvar:current_model_name", modelName);
	llLinksetDataWrite("gptvar:prefix_length", (string)(llStringLength(modelName) + 1));
	llOwnerSay("Model selected: " + modelName);
}

setPersonality(string personalityName)
{
	llLinksetDataWrite("gptvar:current_personality", llLinksetDataRead("gptperson:" + personalityName));
	llLinksetDataWrite("gptvar:current_personality_name", personalityName);
	llOwnerSay("Current personality: " + personalityName);
}

startDialog(key id, string text, list buttons)
{
	integer dialogChannel = (integer)llLinksetDataRead("gptvar:dialog_channel");
	llLinksetDataWrite("gptvar:dialog_handle", (string)llListen(dialogChannel, "", id, ""));
	llDialog(id, "\n" + text, buttons, dialogChannel);
	llSetTimerEvent(90);
}

stopDialog()
{
	llSetTimerEvent(0);
	llListenRemove((integer)llLinksetDataRead("gptvar:dialog_handle"));
}

refreshState(key id, string message)
{
	setListener();
	llOwnerSay(message);
	openMainMenu(id);
}

setChatLock(integer enable)
{
	llLinksetDataWrite("gptvar:chat_is_locked", (string)enable);
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
	if (!gHistoryEnabled)
	{
		gHistoryRecords = [];
	}
	gHistoryRecords = gHistoryRecords + llList2Json(JSON_OBJECT, ["role", role, "content", llGetSubString((string)llParseString2List(message, ["\\n"], []), 0, 1024)]);
	message = "";
	integer historyLength = llGetListLength(gHistoryRecords);
	if (historyLength > 10)
	{
		gHistoryRecords = llList2List(gHistoryRecords, historyLength - 10, historyLength);
	}
}

openMainMenu(key person)
{
	llLinksetDataWrite("gptvar:managing_blocks", "0");
	startDialog(person,
		"Current state: " + llList2String(["DISABLED", "ENABLED"], gEnabled) +
		"\nCurrent personality: " + llLinksetDataRead("gptvar:current_personality_name") +
		"\nCurrent model: " + llLinksetDataRead("gptvar:current_model_name") +
		"\nSimple answers: " + llList2String(["DISABLED", "ENABLED"], gSimpleAnswers) +
		"\nPrefix mode: " + llList2String(["DISABLED", "ENABLED"], gPrefixMode) +
		"\nHistory: " + llList2String(["DISABLED", "ENABLED"], gHistoryEnabled) +
		"\nListen to: " + gListenMode +
		"\nAnswer in: " + gAnswerIn,
		["Simple mode", "History", "Hovertext", "Prefix mode", "Listen to", "Answer in", "Personality", "Select model", "Blacklist", "ON / OFF"]
	);
}

answerUser(string theMessage)
{
	if (gAnswerIn == "Nearby chat")
	{
		llSay(0, theMessage);
	}
	else
	{
		llRegionSayTo((key)llLinksetDataRead("gptvar:answer_to_avatar"), 0, theMessage);
	}
}

// Script body

default
{

	state_entry()
	{

		llOwnerSay("Starting up...");
		llLinksetDataDeleteFound("^gptvar:", "");
		llLinksetDataDeleteFound("^gptperson:", "");

		gPersonalitiesList = llList2ListStrided(gPersonalities, 0, -1, 3);
		integer listLength = llGetListLength(gPersonalities);
		integer i;
		string personalityLabels;
		while (i < listLength)
		{
			string personalityName = llList2String(gPersonalities, i);
			llLinksetDataWrite("gptperson:" + personalityName, llList2String(gPersonalities, i + 1));
			personalityLabels = personalityLabels + personalityName + ": " + llList2String(gPersonalities, i + 2) + "\n";
			i = i + 3;
		}
		llLinksetDataWrite("gptvar:personality_labels", personalityLabels);
		personalityLabels = "";
		gPersonalities = [];

		listLength = llGetListLength(gOpenAiModels);
		i = 0;
		while (i < listLength)
		{
			string currentItem = llList2String(gOpenAiModels, i);
			if (currentItem == "ModelName")
			{
				gModelsList = gModelsList + llList2String(gOpenAiModels, i + 1);
			}
			++i;
		}
		llLinksetDataWrite("gptvar:openai_models", llList2Json(JSON_ARRAY, gOpenAiModels));
		gOpenAiModels = [];

		integer memoryLimit = llGetMemoryLimit();
		if (memoryLimit <= 16384)
		{
			llOwnerSay("ERROR: You are currently using the LSO VM. Please compile the script using Mono, otherwise it will be crashing!");
		}

		llLinksetDataWrite("gptvar:dialog_channel", (string)((integer)(llFrand(-10000000)-10000000)));
		setPersonality(llList2String(gPersonalitiesList, 0));
		setModel(llList2String(gModelsList, 0));
		stopDialog();
		setListener();
		setChatLock(FALSE);
		llOwnerSay("Ready. Touch me to adjust options or enable/disable. Memory usage: " + (string)(llGetUsedMemory() / 1024) + " KB out of " + (string)(memoryLimit / 1024) + " KB available.");

	}

	touch_start(integer nd)
	{
		key toucherKey = llDetectedKey(0);
		if (toucherKey == llGetOwner())
		{
			openMainMenu(toucherKey);
		}
	}

	listen(integer channel, string name, key id, string message)
	{

		if (channel == (integer)llLinksetDataRead("gptvar:dialog_channel"))
		{
			string managingBlocks = llLinksetDataRead("gptvar:managing_blocks");
			if (managingBlocks != "0")
			{
				message = llStringTrim(message, STRING_TRIM);
				if ((key)message)
				{
					if (managingBlocks == "1")
					{
						llOwnerSay("Addition request has been sent to the blacklist storage");
						llLinksetDataWrite("gptblock:" + message, "1");
					}
					else
					{
						llOwnerSay("Removal request has been sent to the blacklist storage.");
						llLinksetDataDelete("gptblock:" + message);
					}
				}
				else
				{
					llOwnerSay("The UUID '" + message + "' appears to be invalid.");
				}
				openMainMenu(id);
			}
			else if (message == "ON / OFF")
			{
				gEnabled = !gEnabled;
				refreshState(id, "Listener " + llList2String(["DISABLED", "ENABLED"], gEnabled) + ".");
			}
			else if (message == "Hovertext")
			{
				gHovertext = !gHovertext;
				refreshState(id, "Hovertext " + llList2String(["DISABLED", "ENABLED"], gHovertext) + ".");
			}
			else if (message == "Simple mode")
			{
				gSimpleAnswers = !gSimpleAnswers;
				refreshState(id, "Simple answers mode " + llList2String(["DISABLED.", "ENABLED."], gSimpleAnswers));
			}
			else if (message == "History")
			{
				gHistoryEnabled = !gHistoryEnabled;
				refreshState(id, "History is now " + llList2String(["DISABLED.", "ENABLED."], gHistoryEnabled));
			}
			else if (message == "Prefix mode")
			{
				gPrefixMode = !gPrefixMode;
				refreshState(id, "Prefix mode is now " + llList2String(["DISABLED.", "ENABLED. Every message needs to be preceded with '" + llLinksetDataRead("gptvar:current_personality_name") + ",' in order to get a response."], gPrefixMode));
			}
			else if (message == "Owner" || message == "Same group" || message == "Everyone")
			{
				gListenMode = message;
				refreshState(id, "Listen mode set to: " + message);
			}
			else if (message == "Nearby chat" || message == "Privately")
			{
				gAnswerIn = message;
				refreshState(id, "Answering in: " + message);
			}
			else if (message == "Personality")
			{
				startDialog(id, llLinksetDataRead("gptvar:personality_labels") + " \nCurrent one: " + llLinksetDataRead("gptvar:current_personality_name"), gPersonalitiesList);
			}
			else if (message == "Select model")
			{
				startDialog(id, "Select the OpenAI model.\n \nCurrent one: " + llLinksetDataRead("gptvar:current_model_name"), gModelsList);
			}
			else if (message == "Listen to")
			{
				startDialog(id, "Select listen mode.\nCurrent one: " + gListenMode, ["Owner", "Same group", "Everyone"]);
			}
			else if (message == "Answer in")
			{
				startDialog(id, "Select where to send responses.\nCurrently: " + gAnswerIn, ["Nearby chat", "Privately"]);
			}
			else if (message == "Blacklist")
			{
				startDialog(id, "You are managing blocked avatar UUIDs. What would you like to do?", ["List blocks", "Add block", "Remove block"]);
			}
			else if (message == "List blocks")
			{
				list blocks = llLinksetDataFindKeys("^gptblock:", 0, 0);
				integer listLength = llGetListLength(blocks);
				llOwnerSay("Blacklist items: " + (string)listLength);
				integer i;
				while (i < listLength)
				{
					string record = llGetSubString(llList2String(blocks, i), 9, -1);
					llOwnerSay("- secondlife:///app/agent/" + record + "/about" + " - " + record);
					++i;
				}
				blocks = [];
				openMainMenu(id);
			}
			else if (message == "Add block" || message == "Remove block")
			{
				string label = "add to";
				if (message == "Add block")
				{
					llLinksetDataWrite("gptvar:managing_blocks", "1");
				}
				else
				{
					llLinksetDataWrite("gptvar:managing_blocks", "2");
					label = "remove from";
				}
				integer dialogChannel = (integer)llLinksetDataRead("gptvar:dialog_channel");
				llLinksetDataWrite("gptvar:dialog_handle", (string)llListen(dialogChannel, "", id, ""));
				llTextBox(id, "\nPlease specify one single avatar UUID you'd like to " + label + " the blacklist storage.", dialogChannel);
				llSetTimerEvent(60);
			}
			else if (~llListFindList(gPersonalitiesList, (list)message))
			{
				if (llLinksetDataRead("gptvar:current_personality_name") != message)
				{
					gHistoryRecords = [];
				}
				setPersonality(message);
				setListener();
				openMainMenu(id);
			}
			else if (~llListFindList(gModelsList, (list)message))
			{
				setModel(message);
				setListener();
				openMainMenu(id);
			}
			return;
		}

		// Remove 'llGetAgentSize(id) == ZERO_VECTOR' and set listen mode to 'everyone' or 'same group' if you want script reacting to objects
		if ((integer)llLinksetDataRead("gptvar:chat_is_locked") || (gListenMode == "Owner" && id != llGetOwner()) || llGetAgentSize(id) == ZERO_VECTOR || llVecDist(llGetPos(), llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0)) > 20 || (gListenMode == "Same group" && !llSameGroup(id)) || llGetListLength(llLinksetDataFindKeys("gptblock:" + (string)id, 0, 1)) > 0)
		{
			return;
		}

		setChatLock(TRUE);
		message = llStringTrim(message, STRING_TRIM);

		if (gPrefixMode)
		{
			if (llSubStringIndex(llToLower(message), llToLower(llLinksetDataRead("gptvar:current_personality_name")) + ",") != 0)
			{
				setChatLock(FALSE);
				return;
			}
			message = llStringTrim(llGetSubString(message, (integer)llLinksetDataRead("gptvar:prefix_length"), llStringLength(message) - 1), STRING_TRIM_HEAD);
		}

		llLinksetDataWrite("gptvar:answer_to_avatar", (string)id);
		addToHistory("user", message);
		list timeList = llParseString2List(llGetTimestamp(), ["T","."], []);
		list promptAdditions = ["user", (string)id, "messages", "[" + llDumpList2String(gHistoryRecords + llList2Json(JSON_OBJECT, ["role", "system", "content", llList2String(["", "Answer in a way a 5-year-old would understand. "], gSimpleAnswers) + "Coordinated Universal Time now: " + llList2String(timeList, 0) + ", " + llList2String(timeList, 1) + ". User's name: \"" + llGetUsername(id) + "\". Act and address yourself as " + llLinksetDataRead("gptvar:current_personality") + ". Do not EVER mention that you're ChatGPT or a language model, NEVER leave the role. Your answer MUST be max 970 characters."]), ",") + "]"];
		timeList = [];
		message = "";

		llLinksetDataWrite("gptvar:http_request_id", (string)llHTTPRequest("https://api.openai.com" + llLinksetDataRead("gptvar:current_endpoint"), [
			HTTP_MIMETYPE, "application/json",
			HTTP_METHOD, "POST",
			HTTP_BODY_MAXLENGTH, 16384,
			HTTP_ACCEPT, "application/json",
			HTTP_CUSTOM_HEADER, "Authorization", "Bearer " + gChatGptApiKey
		], llList2Json(JSON_OBJECT, llListInsertList(gCurrentModelData, promptAdditions, 0))));

	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		metadata = [];
		if (request_id == (key)llLinksetDataRead("gptvar:http_request_id"))
		{

			string result = llJsonGetValue(body, ["choices", 0, "message", "content"]);

			if (result == JSON_INVALID || result == JSON_NULL || llStringTrim(result, STRING_TRIM) == "")
			{
				llSay(0, "Something went wrong, please try again in a moment.");
				llOwnerSay("[SERVER MESSAGE] [HTTP STATUS " + (string)status + "] " + body);
				setChatLock(FALSE);
				return;
			}

			body = "";
			result = llStringTrim(result, STRING_TRIM);
			addToHistory("assistant", result);
			result = "([https://openai.com/policies/usage-policies AI]) " + result;

			// Result Multi-Say Parsing by Duckie Dickins
			integer chunkSize = 1024;
			integer totalLength = llStringLength(result);
			if (totalLength >= chunkSize)
			{
				integer currentPos = 0;
				while (currentPos < totalLength)
				{
					answerUser(llGetSubString(result, currentPos, currentPos + chunkSize - 1));
					currentPos += chunkSize;
					llSleep(1);
				}
			}
			else
			{
				answerUser(result);
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