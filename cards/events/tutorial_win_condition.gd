extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.map.position = GameState.TRAVEL_GOAL / 2.0;
	GameState.new_phase.emit(GameState.current_phase);
	
	event_title = "Tutorial: Winning";
	event_text = "To win you need to:\n1) Reach 100% travel progress. The progress is tracked by the bar above.\n2) Be on the first layer of the Hyperspace.\nThe deeper you go into the Hyperspace, the faster you travel. At the end of the game, you get a score, based on how many Adamantine you have and how fast you reached the finish line.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(EventLoader.EventID.TUTORIAL_MANNING);
	
	super._ready();
