extends FlyEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_image = preload("res://assets/graphics/events/ev_progress.png");
	
	if not GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES):
		event_image = preload("res://assets/graphics/events/ev_notravel.png");
	
	event_title = "Another Day";
	event_text = "It's time to schedule repairs and plan ahead.";
