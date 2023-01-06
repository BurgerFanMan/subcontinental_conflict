// internal
#include "gamemode.as"
#include "tracker.as"
#include "log.as"

//Author: BurgerFanMan

// --------------------------------------------
class HalnoDialogue : Tracker {
	protected Metagame@ m_metagame;
	
	HalnoDialogue(Metagame@ metagame) {
		@m_metagame = @metagame;

		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}

	// --------------------------------------------
	void update(float time) {

	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}

	// --------------------------------------------
	protected void handleItemDropEvent(const XmlElement@ event) {
		int commonessInMillion = 5000; //0.5% chance to trigger
		int r = rand(1, 1000000);	

		int containerId = event.getIntAttribute("target_container_type_id");
		if (containerId == 2 && r <= commonessInMillion) {
			int characterId = event.getIntAttribute("character_id");
			//Announcing item description when picking up a weapon
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "halno_dialogue, equip");
		}
	}

	// --------------------------------------------
	protected void handleCharacterKillEvent(const XmlElement@ event) {
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		int playerId = killer.getIntAttribute("player_id");

		if(playerId < 0){
			return;
		}

		int commonessInMillion = 1000; //0.1% chance to trigger
		int r = rand(1, 1000000);	

		if (killer !is null && r <= commonessInMillion) 
		{
			int characterId = findPlayerById(m_metagame, playerId).getIntAttribute("character_id");
			
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "halno_dialogue, kill");
		}
	}

	// --------------------------------------------
	protected void handlePlayerWoundEvent(const XmlElement@ event) {
		const XmlElement@ target = event.getFirstElementByTagName("target");
		int playerId = target.getIntAttribute("player_id");

		if(playerId < 0){
			return;
		}

		int commonessInMillion = 1000; //0.1% chance to trigger
		int r = rand(1, 1000000);	

		if (target !is null && r <= commonessInMillion) 
		{
			int characterId = findPlayerById(m_metagame, playerId).getIntAttribute("character_id");
			
			sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "halno_dialogue, wounded");
		}
	}

}

