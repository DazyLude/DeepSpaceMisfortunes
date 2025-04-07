extends GenericEvent


const damage_threshold : int = 10;


func _action() -> void:
	GameState.travel_distance -= 3.0;
	GameState.travel_distance = maxf(GameState.travel_distance, 0.0);


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Space Police";
	event_image = preload("res://assets/graphics/events/ev_progress.png");
	event_text = "You get escorted a bit to where you came from, but make a lucky break and escape.";
	
	
	super._ready();
