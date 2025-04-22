extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship = GameState.ShipState.new();
	GameState.new_phase.emit(GameState.current_phase);
	GameState.reset_tokens();
	
	
	event_title = "Tutorial: Progression";
	event_text = "The game is divided in rounds. Rounds advance through 4 phases: Navigation phase, Progress phase, Event phase and Autopilot phase. Working crew members keep manning their systems until the end of the round. Only the systems manned during the Navigation phase are repaired.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(EventLoader.EventID.TUTORIAL_LOSE_CONDITION);
	
	super._ready();
