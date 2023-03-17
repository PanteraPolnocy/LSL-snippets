// Written by PanteraPolnocy

default
{
    touch_start (integer num)
    {
        list Roleplay = [
            "hello!",
            "hi!",
            "what a nice day!"
        ];
        llSay(0, llGetDisplayName(llDetectedKey(0)) + " " + llList2String(llListRandomize(Roleplay, 1), 0));
    }
}
