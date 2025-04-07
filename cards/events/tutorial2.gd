extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Tutorial 2";
	event_text = "This window you're looking at right now, unless you can read things without looking at them, is the event card.\n"\
		+ "It contains a description of the current game event, as well as (sometimes) optional choices you can make.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.TUTORIAL3);
	
	super._ready();
