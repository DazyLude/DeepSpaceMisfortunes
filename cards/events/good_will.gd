extends GenericEvent


func _action() -> void:
	GameState.round_n -= 3;
	GameState.ship.full_repair();


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "The Good Will";
	event_text = "You bask in the light of brilliance, neverending warmth fills you. You can do it. You have it in you.";
	event_image = preload("res://assets/graphics/events/ev_will.png");
	
	super._ready();
