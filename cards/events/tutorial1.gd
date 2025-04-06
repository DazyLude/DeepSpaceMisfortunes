extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.clear_tokens.emit();
	
	event_title = "Tutorial 1";
	event_text = "Hi! This is a small slide show that explains the core game mechanics.\n"\
		+ "First of all, at any stage of the game, you need to press the button in the bottom right corner of the screen to progress.\n"\
		+ "Do it right now! :)";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.TUTORIAL2);
	
	super._ready();
