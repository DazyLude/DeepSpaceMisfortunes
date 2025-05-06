extends FlyEvent


func _action() -> void:
	var speed : float = GameState.get_speed(GameState.map.layer);
	
	if not GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES):
		speed = 0;
	
	var move_command = MapState.MovementCommand.new(speed, 1, GameState.map.layer);
	GameState.map.free_move(move_command);


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Time Dilation!";
	event_text = "At this level of hyperspace, time behaves finicky. "\
		+ "You feel as if no time has passed at all, but ship's readings tell you the opposite. Something else is coming...";
	event_image = preload("res://assets/graphics/events/ev_time.png");
	
	
	if GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES):
		event_text += " But at least you got closer to your destination!"
	
	GameState.add_callable_to_queue(
		func():
			var event = GameState.map.pull_random_event().unwrap();
			GameState.new_event.emit(event);
	);
