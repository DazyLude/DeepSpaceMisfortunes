extends GenericEvent


const damage_threshold : int = 10;


func _action() -> void:
	var should_repair = GameState.ship.get_total_damage() > damage_threshold \
		or not GameState.ship.is_system_ok(GameState.ShipState.System.LIFE_SUPPORT);
	
	if should_repair:
		GameState.ship.full_repair();
	else:
		GameState.ingot_count += 1;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "A Fellow Space Pirate";
	
	var should_repair = GameState.ship.get_total_damage() > damage_threshold \
		or not GameState.ship.is_system_ok(GameState.ShipState.System.LIFE_SUPPORT);
	
	if should_repair:
		event_text = "He decides to help you by fixing your ship.";
	else:
		event_text = "He decides to share some of his adamantine with you.";
	
	super._ready();
