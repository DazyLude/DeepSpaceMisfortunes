extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.clear_tokens.emit();
	
	event_title = "Tutorial";
	event_text = "Hi! This is a small slide show that explains the core game mechanics.\n"\
		+ "First of all, at any stage of the game, you need to press the button in the bottom right corner of the screen to progress.\n"\
		+ "Do it right now! :)";
	
	GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_EVENTS);
	
	super._ready();
