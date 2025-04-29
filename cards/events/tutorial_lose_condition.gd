extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Tutorial: Losing";
	event_text = "You lose the game, if the Life Support is broken at the beginning of the Autopilot phase twice in a row.";
	
	GameState.event_queue.push_back(EventLoader.EventID.TUTORIAL_WIN_CONDITION);
	
	super._ready();
