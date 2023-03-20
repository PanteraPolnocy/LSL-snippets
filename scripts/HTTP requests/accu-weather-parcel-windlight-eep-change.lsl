// Written by PanteraPolnocy

string gApiLink = "https://dataservice.accuweather.com/currentconditions/v1/265984?apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&details=false";
string gCityName = "ZZZZZZZZZZZZZZZZZZZZZZ";
key gHttpRequestId;
string gLastWeatherData;

checkWeather()
{
	gHttpRequestId = llHTTPRequest(gApiLink, [HTTP_BODY_MAXLENGTH, 16384], "");
}

setWeather(string environment)
{
	integer test = llReplaceEnvironment(llGetPos(), environment, -1, 86400, 7200);
	if (test == ENV_NO_ENVIRONMENT)
	{
		llOwnerSay("The environment inventory object '" + environment + "' could not be found.");
	}
	else if (test == ENV_THROTTLE)
	{
		llOwnerSay("The scripts have exceeded the throttle. Wait and retry the request.");
	}
	else if (test == ENV_NO_PERMISSIONS)
	{
		llOwnerSay("The script does not have permission to change the environment at the selected location. Or: There was an attempt to remove altitude track 0 or 1.");
	}
}

default
{

	state_entry()
	{
		checkWeather();
		llSetMemoryLimit(llGetUsedMemory() + 32768);
		llSetTimerEvent(3600);
	}

	on_rez(integer sp)
	{
		llResetScript();
	}

	timer()
	{
		checkWeather();
	}

	http_response(key request_id, integer status, list metadata, string body)
	{
		if (request_id == gHttpRequestId)
		{

			string weatherText = llJsonGetValue(body, ["0", "WeatherText"]);
			string weatherIcon = llJsonGetValue(body, ["0", "WeatherIcon"]);
			string observationTime = llJsonGetValue(body, ["0", "LocalObservationDateTime"]);
			string temperatureC = llJsonGetValue(body, ["0", "Temperature", "Metric", "Value"]);
			string temperatureF = llJsonGetValue(body, ["0", "Temperature", "Imperial", "Value"]);
			string link = llJsonGetValue(body, ["0", "Link"]);
			if (
				weatherText == JSON_INVALID ||
				weatherIcon == JSON_INVALID ||
				observationTime == JSON_INVALID ||
				temperatureC == JSON_INVALID ||
				temperatureF == JSON_INVALID ||
				link == JSON_INVALID
			)
			{
				llOwnerSay("Error parsing AccuWeather data.");
				return;
			}
			gLastWeatherData = "\nWeather in [" + link + " " + gCityName + "]:\n" + weatherText + ", " + temperatureC + " C / " + temperatureF + " F\n" + observationTime;
			llSetText(temperatureC + " C / " + temperatureF + " F", <1, 1, 1>, 0.3);

			integer weatherIconNum = (integer)weatherIcon;
			if (weatherIconNum == 1 || weatherIconNum == 33) // Sunny, Clear
			{
				setWeather("Clear");
			}
			else if (weatherIconNum == 2 || weatherIconNum == 34) // Mostly Sunny, Mostly Clear
			{
				setWeather("MostlyClear");
			}
			else if (weatherIconNum == 3 || weatherIconNum == 35) // Partly Sunny, Partly Cloudy
			{
				setWeather("PartlyCloudy");
			}
			else if (weatherIconNum == 4 || weatherIconNum == 36) // Intermittent Clouds
			{
				setWeather("IntermittentClouds");
			}
			else if (weatherIconNum == 5 || weatherIconNum == 37) // Hazy Sunshine, Hazy Moonlight
			{
				setWeather("Hazy");
			}
			else if (weatherIconNum == 6 || weatherIconNum == 38) // Mostly Cloudy
			{
				setWeather("MostlyCloudy");
			}
			else if (weatherIconNum == 7) // Cloudy
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 8) // Dreary (depressing)
			{
				setWeather("DrearyDepressing");
			}
			else if (weatherIconNum == 11) // Fog
			{
				setWeather("Fog");
			}
			else if (weatherIconNum == 12) // Showers
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 13 || weatherIconNum == 40) // Mostly Cloudy w/ Showers
			{
				setWeather("MostlyCloudy");
			}
			else if (weatherIconNum == 14 || weatherIconNum == 39) // Partly Sunny (Cloudy) w/ Showers
			{
				setWeather("PartlyCloudy");
			}
			else if (weatherIconNum == 15) // T-Storms
			{
				setWeather("T-Storms");
			}
			else if (weatherIconNum == 16 || weatherIconNum == 42) // Mostly Cloudy w/ T-Storms
			{
				setWeather("T-Storms");
			}
			else if (weatherIconNum == 17 || weatherIconNum == 41) // Partly Sunny (Cloudy) w/ T-Storms
			{
				setWeather("T-Storms");
			}
			else if (weatherIconNum == 21) // Partly Sunny w/ Flurries
			{
				setWeather("PartlyCloudy");
			}
			else if (weatherIconNum == 20 || weatherIconNum == 43) // Mostly Sunny (Cloudy) w/ Flurries
			{
				setWeather("MostlyCloudy");
			}
			else if (weatherIconNum == 23 || weatherIconNum == 44) // Mostly Cloudy w/ Snow
			{
				setWeather("Snow");
			}
			else if (weatherIconNum == 18) // Rain
			{
				setWeather("T-Storms");
			}
			else if (weatherIconNum == 19) // Flurries
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 22) // Snow
			{
				setWeather("Snow");
			}
			else if (weatherIconNum == 24) // Ice
			{
				setWeather("Snow");
			}
			else if (weatherIconNum == 25) // Sleet
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 26) // Freezing Rain
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 29) // Rain and Snow
			{
				setWeather("Snow");
			}
			else if (weatherIconNum == 30) // Hot
			{
				setWeather("Clear");
			}
			else if (weatherIconNum == 31) // Cold
			{
				setWeather("Cloudy");
			}
			else if (weatherIconNum == 32) // Windy
			{
				setWeather("MostlyCloudy");
			}

		}
	}

	touch_start(integer total_number)
	{
		key targetAvatar = llDetectedKey(0);
		if (llGetAgentSize(targetAvatar) != ZERO_VECTOR)
		{
			llRegionSayTo(targetAvatar, 0, gLastWeatherData);
		}
		else
		{
			llInstantMessage(targetAvatar, gLastWeatherData);
		}
	}

}
