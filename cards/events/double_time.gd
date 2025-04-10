extends GenericEvent


func _action() -> void:
	var speed : float = GameState.get_speed();
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		speed = 0;
	
	GameState.travel_distance += speed;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Time Dilation!";
	event_text = "At this level of hyperspace, time behaves finicky. "\
		+ "You feel as if no time has passed at all, but ship's readings tell you the opposite. Something else is coming...";
	event_image = preload("res://assets/graphics/events/ev_time.png");
	
	
	if GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		event_text += " But at least you got closer to your destination!"
	
	GameState.interrupt_phase_sequence = func():
		var event = GameState.event_pools[GameState.hyper_depth].pull_random_event();
		GameState.new_event.emit(event);
	
	super._ready();
