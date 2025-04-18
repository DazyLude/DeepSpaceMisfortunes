extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Tutorial: Losing";
	event_text = "You lose the game, if the Life Support is broken at the beginning of the Autopilot phase twice in a row.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.TUTORIAL_WIN_CONDITION);
	
	super._ready();
