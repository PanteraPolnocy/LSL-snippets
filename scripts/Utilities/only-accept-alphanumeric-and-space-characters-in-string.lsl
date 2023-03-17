// Written by PanteraPolnocy

integer testTheName(string testName)
{
    string allowedCharacters = " abcdefghijklmnopqrstuvwxyz";
    integer nameMaxLength = 36;

    testName = llToLower(llStringTrim(testName, STRING_TRIM));
    integer testLength = llStringLength(testName);
    if (testLength == 0 || testLength > nameMaxLength)
    {
        return FALSE;
    }

    integer i;
    while (i < testLength)
    {
        if (llSubStringIndex(allowedCharacters, llGetSubString(testName, i, i)) == -1)
        {
            return FALSE;
        }
        ++i;
    }

    return TRUE;
}

ownerSayWrapper(string thisName)
{
    if (testTheName(thisName))
    {
        llOwnerSay("Name '" + thisName + "' is valid.");
    }
    else
    {
        llOwnerSay("Name '" + thisName + "' is invalid");
    }
}

default
{
    touch_start(integer total_number)
    {
        ownerSayWrapper("Cookie Eater"); // Letters and space
        ownerSayWrapper("CookieEater123"); // Letters and numbers
        ownerSayWrapper("CookieEater"); // Letters without space
        ownerSayWrapper("OrangesBetterThanApples@"); // Letters and a special character
        ownerSayWrapper("Lorem ipsum dolor sit amet, consectetur adipiscing elit"); // Longer than gNameMaxLength
    }
}