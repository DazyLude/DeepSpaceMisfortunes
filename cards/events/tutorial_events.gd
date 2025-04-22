extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Tutorial: Events";
	event_text = "This window you're looking at is the event card. It contains a description of the current game event, as well as (sometimes) optional choices you can make.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(EventLoader.EventID.TUTORIAL_TOKENS);
	
	super._ready();
