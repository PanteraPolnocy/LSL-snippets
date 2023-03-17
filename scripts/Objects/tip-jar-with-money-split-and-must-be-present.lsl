// Written by PanteraPolnocy

string gThankYouMessage = "Thank you for your tip!";

string gNotecardName = "participants";
key gNotecardQueryId;
integer gNotecardLine;

list gParticipants;
integer gParticipantsLength;
integer gDebitPermns;

default
{

    on_rez(integer sp)
    {
        llResetScript();
    }

    state_entry()
    {
        llSetClickAction(CLICK_ACTION_PAY);
        llSetPayPrice(50, [PAY_DEFAULT, PAY_DEFAULT, PAY_DEFAULT, PAY_DEFAULT]);
        if (llGetInventoryKey(gNotecardName) == NULL_KEY)
        {
            llOwnerSay("Notecard '" + gNotecardName + "' missing or unwritten.");
            llSetMemoryLimit(llGetUsedMemory() + 2048);
        }
        else
        {
            gNotecardQueryId = llGetNotecardLine(gNotecardName, 0);
        }
        
    }

    dataserver(key query_id, string data)
    {
        if (query_id == gNotecardQueryId)
        {
            if (data == EOF)
            {
                gParticipantsLength = llGetListLength(gParticipants);
                llOwnerSay("Participants: " + (string)gParticipantsLength);
                if (gParticipantsLength)
                {
                    llOwnerSay("Accept debit perms for money splitting.");
                    llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
                }
                llSetMemoryLimit(llGetUsedMemory() + 10240);
            }
            else
            {
                data = llStringTrim(data, STRING_TRIM);
                key uuid = (key)data;
                if (uuid)
                {
                    gParticipants += uuid;
                }
                ++gNotecardLine;
                gNotecardQueryId = llGetNotecardLine(gNotecardName, gNotecardLine);
            }
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_DEBIT)
        {
            gDebitPermns = TRUE;
        }
    }

    changed(integer change)
    {
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            llResetScript();
        }
    }

    money(key id, integer amount)
    {

        llRegionSayTo(id, 0, gThankYouMessage);

        if (!gDebitPermns || !gParticipantsLength)
        {
            return;
        }

        integer index;
        list present;
        while (index < gParticipantsLength)
        {
            key person = llList2Key(gParticipants, index);
            if (llGetAgentSize(person))
            {
                present += person;
            }
            ++index;
        }

        integer presentAmount = llGetListLength(present);
        if (presentAmount < 1)
        {
            return;
        }

        integer finalAmount;
        integer moduloTest = amount % presentAmount;
        if (moduloTest > 0)
        {
            finalAmount = (amount - moduloTest) / presentAmount;
        }
        else
        {
            finalAmount = amount / presentAmount;
        }

        if (finalAmount < 1)
        {
            return;
        }

        index = 0;
        while (index < presentAmount)
        {
            llGiveMoney(llList2Key(present, index), finalAmount);
            ++index;
        }

    }

}