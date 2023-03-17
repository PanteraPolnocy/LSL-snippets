// Written by PanteraPolnocy

string gBotId = "xxxxxxxxxxxxxxxx"; // bot ID
key gHTTPRequest;
string gCust;

string SearchAndReplace(string input, string old, string new) 
{
    return llDumpList2String(llParseString2List(input, [old], []), new);
}

default
{

    state_entry()
    {
        llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
    }

    on_rez(integer param)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (llGetAgentSize(id) != ZERO_VECTOR) // Accept chat only from avatars, not other objects...
        {
            if (llVecDist(llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0), llGetPos()) <= 20) // These avatars must be within 20m range, as bot replies in 20m range via llSay() as well...
            {
                gHTTPRequest = llHTTPRequest("http://www.pandorabots.com/pandora/talk-xml?botid=" + gBotId + "&input=" + llEscapeURL(llToLower(msg)) + "&custid=" + gCust, [HTTP_METHOD, "POST"], "");
            }
        }
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == gHTTPRequest)
        {
            string reply = llGetSubString(body, llSubStringIndex(body, "<that>") + 6, llSubStringIndex(body, "</that>") - 1);
            reply = SearchAndReplace(reply, "%20", " ");
            reply = SearchAndReplace(reply,"&quot;", "\"");
            reply = SearchAndReplace(reply, "&gt;", ">");
            reply = SearchAndReplace(reply, "&lt;", "<");
            reply = SearchAndReplace(reply,"<br>", "\n");
            llSay(0, reply);
            integer cust_begin = llSubStringIndex(body, "custid=");
            gCust = llGetSubString(body, cust_begin + 8, cust_begin + 23);
        }
    }

}