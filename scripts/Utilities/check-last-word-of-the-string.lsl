// Written by PanteraPolnocy

default
{
    touch_end(integer num)
    {

        string str = "This is the test string";
        string word = "string";

        // Uncomment if you want case-insensitive comparison
        // word = llToLower(word);
        // str = llToLower(str);

        // If you want to detect if string is at the end, regardless of spaces
        // Will say that "abcstring" in str is last

        if (llGetSubString(str, -llStringLength(word), -1) == word) {
            llOwnerSay("The word is last (substring)");
        } else {
            llOwnerSay("The word isn't last (substring)");
        }

        // If you know that words are divided by spaces
        // Will say that "abcstring" in str is not last

        if (llList2String(llParseString2List(str, [" "], []), -1) == word) {
            llOwnerSay("The word is last (list)");
        } else {
            llOwnerSay("The word isn't last (list)");
        }

    }
}