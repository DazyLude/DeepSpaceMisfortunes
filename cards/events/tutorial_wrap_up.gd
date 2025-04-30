extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.ships_crew[ShipState.Crewmate.new()] = -1;
	GameState.reset_tokens();
	
	event_title = "Tutorial: End";
	event_text = "That's it for the main stuff. Have fun :)";
	
	GameState.add_callable_to_queue(GameState.go_to_menu);
	
	super._ready();
