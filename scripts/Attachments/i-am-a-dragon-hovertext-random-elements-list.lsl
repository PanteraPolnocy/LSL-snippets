// Written by PanteraPolnocy
// Because some people just don't get it and see things
// https://www.youtube.com/watch?v=cEWY8ufA-VY

list animals = ["bat", "vampire", "werewolf", "cat", "demon", "giraffe", "dolphin", "snake", "horse", "gecko with wings", "lizard", "shark", "walrus", "woodpecker", "fish", "lemur", "sea serpent", "otter", "dog", "stingray", "fox", "rabbit", "basilisk", "monkey", "duck"];

default
{

    on_rez(integer sp)
    {
        llResetScript();
    }

    state_entry()
    {
        llSetTimerEvent(1);
        llSetMemoryLimit(llGetUsedMemory() + 2048);
    }

    timer()
    {
        llSetText("I AM A DRAGON\nNot a " + llList2String(llListRandomize(animals, 0), 0), <llFrand(1), llFrand(1), llFrand(1)>, 0.75);
    }

}
