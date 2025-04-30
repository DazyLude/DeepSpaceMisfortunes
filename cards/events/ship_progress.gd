extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	var is_goal_reached = GameState.map.position >= GameState.map.start_to_finish_distance;
	
	event_image = preload("res://assets/graphics/events/ev_progress.png");
	
	if not GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES):
		event_image = preload("res://assets/graphics/events/ev_notravel.png");
	
	event_title = "Another Day";
	event_text = "It's time to schedule repairs and plan ahead.";
	
	super._ready();
