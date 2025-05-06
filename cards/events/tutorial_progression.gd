extends FlyEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship = ShipState.new();
	GameState.new_phase.emit(GameState.current_phase);
	GameState.reset_tokens();
	
	
	event_title = "Tutorial: Progression";
	event_text = "The game is divided in rounds. Rounds advance through 4 phases: Navigation phase, Progress phase, Event phase and Autopilot phase. Working crew members keep manning their systems until the end of the round. Only the systems manned during the Navigation phase are repaired.";
	
	GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_LOSE_CONDITION);
