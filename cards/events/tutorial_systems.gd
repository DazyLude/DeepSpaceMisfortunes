extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.reset_tokens();
	
	event_title = "Tutorial: Systems";
	event_text = "The big thing on the left is your ship. It has different systems, which support its functions. Sometimes they break (subtle foreshadowing).";
	
	GameState.event_queue.push_back(EventLoader.EventID.TUTORIAL_DAMAGE_BASIC);
	
	super._ready();
