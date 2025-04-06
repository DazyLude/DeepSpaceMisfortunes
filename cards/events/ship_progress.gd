extends GenericEvent


func _action() -> void:
	var speed : float = GameState.get_speed();
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		speed = 0;
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.NAVIGATION):
		speed /= 2;
	
	GameState.travel_distance += speed;


func _prepare() -> void:
	reset_event_inputs();
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		event_title = "Engines Are Out!";
		event_text = "Your progress is halted when the heart of your ship is standing still."
	
	elif not GameState.ship.is_system_ok(GameStateClass.ShipState.System.NAVIGATION):
		event_title = "Navigation Is Out!";
		event_text = "Your engines are pushing your ship in a direction, but not necessarily in the right one."
	
	else:
		event_title = "Another Day";
		event_text = "The engines murmur their antimatter powered Meganewton song through your ship's hull.\n"\
			+ "You get closer to your destination.";
	
	super._ready();
