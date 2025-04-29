extends GenericEvent


func _action() -> void:
	var is_autopilot_ok := GameState.ship.is_role_ok(ShipState.SystemRole.AUTOPILOT);
	
	var is_engine_there := GameState.ship.has_role(ShipState.SystemRole.ENGINES);
	var is_engine_ok := GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES);
	
	var is_hyper_drive_there := GameState.ship.has_role(ShipState.SystemRole.HYPERDRIVE);
	var is_hyper_drive_ok :=  GameState.ship.is_role_ok(ShipState.SystemRole.HYPERDRIVE);
	
	var is_life_support_there := GameState.ship.has_role(ShipState.SystemRole.LIFE_SUPPORT);
	var is_life_support_ok := GameState.ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT);
	
	match is_autopilot_ok:
		true when is_hyper_drive_there and not is_hyper_drive_ok:
			var slot = GameState.ship.get_broken_system_slot_of_a_role(
				ShipState.SystemRole.HYPERDRIVE
			);
			var strength = GameState.ship.autorepair_strength;
			GameState.ship.repair_system_in_a_slot(slot, strength);
			
		true when is_engine_there and not is_engine_ok:
			var slot = GameState.ship.get_broken_system_slot_of_a_role(
				ShipState.SystemRole.ENGINES
			);
			var strength = GameState.ship.autorepair_strength;
			GameState.ship.repair_system_in_a_slot(slot, strength);
			
		true when is_life_support_there and not is_life_support_ok:
			if GameState.map.layer > 0:
				var depth_value := GameState.map.layer as int - 1;
				depth_value = clampi(depth_value, 0, 3);
				var move_command = MapState.MovementCommand.new(0, 0, depth_value);
				GameState.map.free_move(move_command);


func _prepare() -> void:
	reset_event_inputs();
	
	var is_autopilot_ok := GameState.ship.is_role_ok(ShipState.SystemRole.AUTOPILOT);
	var are_engines_ok :=  GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES) \
		and GameState.ship.is_role_ok(ShipState.SystemRole.HYPERDRIVE);
	
	var is_life_support_ok := GameState.ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT);
	
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
