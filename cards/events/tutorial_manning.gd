extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.ships_crew[ShipState.Crewmate.new()] = -1;
	GameState.reset_tokens();
	
	event_title = "Tutorial: Manning";
	event_text = "A system with one or more crewmembers is considered to be manned, and it is indicated by the icon above it. Most events will deal reduced damage if the targeted system is manned. Some events require the navigation system to be manned to provide additional options.";
	
	GameState.event_queue.push_back(EventLoader.EventID.TUTORIAL_DAMAGE_ELECTRIC);
	
	super._ready();
