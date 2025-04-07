extends GenericEvent


const damage_threshold : int = 10;


func _action() -> void:
	GameState.ingot_count -= 1;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Space Police";
	event_image = preload("res://assets/graphics/events/ev_police.png");
	event_text = "\"Surely there is nothing wrong with my cargo!\" - you say, handing him an adamantine ingot. Cop looks at you, intently, then takes the ingot and leaves.";
	
	
	super._ready();
