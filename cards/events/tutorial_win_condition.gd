extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.travel_distance = GameState.TRAVEL_GOAL / 2.0;
	GameState.new_phase.emit(GameState.current_phase);
	
	event_title = "Tutorial: Winning";
	event_text = "You win the game when the travel progress reaches 100%. The progress is tracked by the bar above. You also have to be on the topmost layer of the Hyperspace to win. However, the deeper you go, the faster the travel progress increases. Your score decreases with the amount of spent rounds, and increases by the amount of Adamantine Ingots that you have by the end.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.TUTORIAL_MANNING);
	
	super._ready();
