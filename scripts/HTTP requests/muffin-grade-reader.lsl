// Written by PanteraPolnocy

key gRequestId;

getGrade()
{
	gRequestId = llHTTPRequest(
		"https://muffinsmilkers.com/Livestock/LiveStockDetails?slKey=" + (string)llGetOwner(),
	[HTTP_BODY_MAXLENGTH, 16384], "");
}

default
{

	on_rez(integer sp)
	{
		llResetScript();
	}

	state_entry()
	{
		getGrade();
		llSetTimerEvent(60 * 10); // Call it each 10 minutes
	}

	timer()
	{
		getGrade();
	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		if (request_id != gRequestId || status != 200)
		{
			return;
		}

		integer pos = llSubStringIndex(body, "/cow-grade-");
		if (~pos)
		{
			string grade = llGetSubString(body, pos + 11, pos + 11); // 11 is the length of '/cow-grade-'
			llOwnerSay("Grade: " + grade);
		}
	}

}