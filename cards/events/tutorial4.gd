extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.ships_crew[GameState.Crewmate.new()] = GameState.ShipState.System.OTHER;
	GameState.reset_tokens();
	
	event_title = "Tutorial 4";
	event_text = "The big thing on the left is your ship.\n"\
		+ "It has different systems, which support its functions. Sometimes they break (subtle foreshadowing). "\
		+ "To fix them, put a crew member in one of the systems."\
		+ "You can stack crew members, so that they wouldn't have to work alone :)";
	
	GameState.interrupt_phase_sequence = GameState.go_to_menu.bind(GameState.active_table);
	
	super._ready();
