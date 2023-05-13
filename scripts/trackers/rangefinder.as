#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17
//Extended by BurgerFanMan

	// --------------------------------------------
class RangeFinder : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	RangeFinder(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
	
		//checking if the event was triggered by a rangefinder notify_script		
		if (event.getStringAttribute("key") == "rangefinder") {
		
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				
				if (player !is null) {
			
					if (player.hasAttribute("aim_target")) {
						Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
						Vector3 origin = stringToVector3(character.getStringAttribute("position"));
						int distance = int(getPositionDistance(target, origin));
						
						string intelKey = "advanced binoculars, direction";
						dictionary a = {
							{"%range", formatInt(distance)},
							{"%target", getClosestTargetString(target)},
							{"%direction", "" + getAngleBetweenPositions(origin, target)}
						};					
						
						sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, intelKey, a);
					}
				}
			}
		}
	}

	// --------------------------------------------
	string getClosestTargetString(Vector3 position){
		//Picks random text from array to replace %target with
		array<string> vehicleGroupSpotted  = { //Checks for large amount of vehicles in area
			"Enemy vehicles spotted!",
			"Watch out! Enemy vehicles!"
		};
		array<string> infantryGroupSpotted = { //Checks for large amount of infantry in area
			"Enemy infantry! A lot of them!",
			"Oh wow that's a lot of tangos!",
			"Large enemy infantry group!"
		};
		array<string> vehicleSpotted  = {
			"Enemy vehicle spotted!",
			"There! Enemy vehicle!"
		};
		array<string> infantrySpotted = {
			"Enemy infantry spotted!",
			"I see enemy troops!",
			"Enemy infantry!"
		};
		array<string> loneInfantrySpotted = {
			"I see an enemy soldier!",
			"An enemy troop! He's alone!"
		};
		

		array<const XmlElement@>@ infantry = getCharactersNearPosition(m_metagame, position, 1, 8.0f);
		array<const XmlElement@>@ infantryGroup = getCharactersNearPosition(m_metagame, position, 1, 20.0f);
		
		array<const XmlElement@>@ vehicles = getVehiclesNearPosition(m_metagame, position, 1, 10.0f);
		array<const XmlElement@>@ vehicleGroup = getVehiclesNearPosition(m_metagame, position, 1, 25.0f);

		//Ordered in terms of priority
		if(vehicleGroup.size() >= 3){
			return getRandomInArray(vehicleGroupSpotted);
		}
		if(infantryGroup.size() >= 10){
			return getRandomInArray(infantryGroupSpotted);
		}
		if(vehicles.size() > 0){
			return getRandomInArray(vehicleSpotted);
		}
		if(infantry.size() > 1){
			return getRandomInArray(infantrySpotted);
		}
		if(infantry.size() > 0){
			return getRandomInArray(loneInfantrySpotted);
		}

		//No enemies found
		return "";
	}

	//Unused
	// --------------------------------------------
	const XmlElement@ getClosestElement(array<const XmlElement@>@ elementArray, Vector3 position){
		int shortestDistance = 1000;
		int index = 0;
		for(uint i = 0; i < elementArray.size(); i++){
			const XmlElement@ element = elementArray[i];

			Vector3 elementPos = stringToVector3(element.getStringAttribute("position"));
			int distance = int(getPositionDistance(elementPos, position));

			if(distance < shortestDistance){
				shortestDistance = distance;
				index = i;
				}
		}

		return elementArray[index];
	}

	// --------------------------------------------
	string getRandomInArray(array<string> stringArray){
			int r = rand(0, stringArray.size() - 1);

			return stringArray[r];
	}
}