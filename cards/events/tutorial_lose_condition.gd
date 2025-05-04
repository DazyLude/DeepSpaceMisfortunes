extends FlyEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Tutorial: Losing";
	event_text = "You lose the game, if the Life Support is broken at the beginning of the Autopilot phase twice in a row.";
	
	GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_WIN_CONDITION);
	
	super._ready();
