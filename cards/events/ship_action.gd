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
	
	else:
		event_title = "Autopilot Greets You";
		event_text = "\"All systems green, Captain!\" - you hear the autopilot's cheery voice through ship's audio system" ;
		
		if are_engines_ok and is_life_support_ok:
			event_text += "."
		
		if not are_engines_ok and is_life_support_ok:
			event_text += ", - \"Almost all of them, at least! Diverting power to fix the engines, Captain!\""
		
		if not is_life_support_ok and are_engines_ok:
			event_text += ", - \"Almost all of them, at least!"\
				+ " Diverting power to engines to get you out of here, Captain!\"";
		
		if not is_life_support_ok and not are_engines_ok:
			event_text += ", - \"Nevermind that! Everything is on fire! Diverting power to fix the engines, Captain!\"";
	
	super._ready();
