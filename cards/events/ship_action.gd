extends GenericEvent


func _action() -> void:
	var is_autopilot_ok := GameState.ship.is_system_ok(GameStateClass.ShipState.System.AUTOPILOT);
	var is_engine_ok := GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES);
	var is_hyper_drive_ok :=  GameState.ship.is_system_ok(GameStateClass.ShipState.System.HYPER_ENGINES);
	var is_life_support_ok := GameState.ship.is_system_ok(GameStateClass.ShipState.System.LIFE_SUPPORT);
	
	if not is_autopilot_ok:
		return;
	
	if not is_hyper_drive_ok:
		GameState.ship.repair_system(GameStateClass.ShipState.System.HYPER_ENGINES);
	elif not is_engine_ok:
		GameState.ship.repair_system(GameStateClass.ShipState.System.ENGINES);
	elif not is_life_support_ok:
		if GameState.hyper_depth > 0:
			GameState.hyper_depth -= 1;


func _prepare() -> void:
	reset_event_inputs();
	
	var is_autopilot_ok := GameState.ship.is_system_ok(GameStateClass.ShipState.System.AUTOPILOT);
	var are_engines_ok :=  GameState.ship.is_system_ok(GameStateClass.ShipState.System.ENGINES) \
		and GameState.ship.is_system_ok(GameStateClass.ShipState.System.HYPER_ENGINES);
	
	var is_life_support_ok := GameState.ship.is_system_ok(GameStateClass.ShipState.System.LIFE_SUPPORT);
	
	if not is_autopilot_ok:
		event_title = "Autopilot Is Out!";
		event_text = "Silence greets you."
		event_image = preload("res://assets/graphics/events/ev_autopilot ded.png");
	
	else:
		event_title = "Autopilot Greets You";
		event_text = "\"All systems green, Captain!\" - you hear the always cheery autopilot's voice through the ship's audio system" ;
		event_image = preload("res://assets/graphics/events/ev_autopilot.png");
		
		match [are_engines_ok, is_life_support_ok]:
			[true, true]:
				event_text += "."
			[false, true]:
				event_text += ", - \"Almost all of them, at least! Diverting power to fix the engines, Captain!\""
			[true, false]:
				event_text += ", - \"Almost all of them, at least!"\
					+ " Diverting power to engines to get you out of here, Captain!\"";
			[false, false]:
				event_text += ", - \"Nevermind that! Everything is on fire! Diverting power to fix the engines, Captain!\"";
	
	super._ready();
