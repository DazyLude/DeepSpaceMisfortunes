extends GenericEvent


func _action() -> void:
	var speed : float;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			speed = 0.1;
		GameState.HyperspaceDepth.SHALLOW:
			speed = 0.4;
		GameState.HyperspaceDepth.NORMAL:
			speed = 1.6;
		GameState.HyperspaceDepth.DEEP:
			speed = 6.0;
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		speed = 0;
	
	GameState.travel_distance += speed;


func _prepare() -> void:
	reset_event_inputs();
	
	if not GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES):
		event_title = "Engines Are Out! ";
		event_text = "Your progress is halted when the heart of your ship is standing still."
	
	else:
		event_title = "Another Day";
		event_text = "The engines murmur their Meganewton powered song through your ship's hull.\n"\
			+ "You get closer to your destination.";
	
	super._ready();
