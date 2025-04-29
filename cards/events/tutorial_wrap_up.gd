extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.ships_crew[ShipState.Crewmate.new()] = -1;
	GameState.reset_tokens();
	
	event_title = "Tutorial: End";
	event_text = "That's it for the main stuff. Have fun :)";
	
	GameState.callable_queue.push_back(GameState.go_to_menu.bind(GameState.active_table));
	
	super._ready();
