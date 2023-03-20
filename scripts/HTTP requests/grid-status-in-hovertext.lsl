// Written by PanteraPolnocy

key gHttpRequestId1;
key gHttpRequestId2;
string gBuildText;

checkData()
{
	gBuildText = "";
	gHttpRequestId1 = llHTTPRequest("http://secondlife.com/xmlhttp/secondlife.php", [HTTP_BODY_MAXLENGTH, 4096], "");
}

string cutString(string theData, string theTag)
{
	integer cutStart = llSubStringIndex(theData, "<" + theTag + ">") + llStringLength("<" + theTag + ">");
	integer cutEnd = llSubStringIndex(theData, "</" + theTag + ">") - 1;
	return llGetSubString(theData, cutStart, cutEnd);
}

default
{

	state_entry ()
	{
		llSetTimerEvent(3600);
		checkData();
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	timer()
	{
		checkData();
	}

	touch_start(integer sp)
	{
		key targetAvatar = llDetectedKey(0);
		if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
		{
			llRegionSayTo(targetAvatar, 0, gBuildText);
		}
		else
		{
			llInstantMessage(targetAvatar, gBuildText);
		}
	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		if (request_id == gHttpRequestId1)
		{
			gBuildText += "Updated: " + llGetTimestamp();
			if (status == 200 && llSubStringIndex(body, "<status>") != -1)
			{
				gBuildText += "\nGrid: " + cutString(body, "status");
				gBuildText += " | Inworld: " + cutString(body, "inworld");
				gBuildText += "\nSignups: " + cutString(body, "signups");
				gBuildText += " | Logged in past 60 days: " + cutString(body, "logged_in_last_60");
			}
			gHttpRequestId2 = llHTTPRequest("http://status.secondlifegrid.net/history.rss", [HTTP_BODY_MAXLENGTH, 4096], "");
		}
		else if (request_id == gHttpRequestId2)
		{
			if (status == 200 && llSubStringIndex(body, "<item>") != -1)
			{
				string commitData = cutString(body, "item");
				gBuildText += "\n---\n" + cutString(commitData, "title");
				gBuildText += "\n" + cutString(commitData, "link");
				gBuildText += "\n" + cutString(commitData, "pubDate");
			}
			llSetText(gBuildText, <1,1,1>, 1);
		}
	}

}
