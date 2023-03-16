// Written by PanteraPolnocy

vector gTargetPosition;

default
{

    touch_start(integer nd)
    {
        gTargetPosition = <123, 123, 123>;
        llSetTimerEvent(0.25);
    }

    timer()
    {
        vector currentPos = llGetPos();
        vector positionLeft = gTargetPosition - currentPos;
        float distanceLeft = llVecMag(positionLeft);
        if (distanceLeft < 1.0 || gTargetPosition == currentPos)
        {
            llSetTimerEvent(0);
            llStopMoveToTarget();
        }
        else
        {
            if (distanceLeft < 65)
            {
                llMoveToTarget(gTargetPosition, 0.05);
            }
            else
            {
                llMoveToTarget(currentPos + llVecNorm(positionLeft) * 60, 0.05);
            }
        }
    }

}