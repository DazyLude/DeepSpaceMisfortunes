extends GenericEvent


var course : int = -1;


func course_chosen(_card, which: int) -> void:
	course = which;


func course_unchosen(_card) -> void:
	course = -1;


func _can_play() -> bool:
	return course != -1;


func _action() -> void:
	if course == -1:
		return;
	
	GameState.hyper_depth += course - 1;
	GameState.hyper_depth = clampi(GameState.hyper_depth, 0, 3);
	course = -1;


func _prepare() -> void:
	reset_event_inputs();
	
	var are_drives_ok = GameState.ship.is_role_ok(ShipState.SystemRole.HYPERDRIVE);
	var is_nav_ok = GameState.ship.is_role_ok(ShipState.SystemRole.NAVIGATION);
	var is_goal_reached = GameState.travel_distance >= GameState.TRAVEL_GOAL;
	
	if not are_drives_ok:
		event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
		event_title = "Hyper Drive is out!";
		event_text = "You can't manually change the Hyperspace level when Hyper Drive is out of commission."
		var stay_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "I guess I'll stay");
		setup_event_signals(stay_idx, course_chosen.bind(1), course_unchosen);
	
	elif not is_nav_ok:
		event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
		event_title = "Navigation is out!";
		event_text = "You can't manually change the Hyperspace level if your bridge is busted."
		var stay_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "I guess I'll fix it");
		setup_event_signals(stay_idx, course_chosen.bind(1), course_unchosen);
	
	else:
		event_image = preload("res://assets/graphics/events/ev_navigat.png");
		event_title = "Choose Ship's Course";
		match GameState.hyper_depth:
			GameState.HyperspaceDepth.NONE:
				event_text = "You can choose whether to stay on the safe surface of the normal Space, "\
					+ "or to descend into the waters of Hyperspace. "\
					+ "The deeper you are - the faster you travel, but the dangers of Space are more extreme as well.";
				
				var stay_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Stay on this level");
				setup_event_signals(stay_idx, course_chosen.bind(1), course_unchosen);
				
				var descent_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Go deeper");
				setup_event_signals(descent_idx, course_chosen.bind(2), course_unchosen);
			
			GameState.HyperspaceDepth.SHALLOW, GameState.HyperspaceDepth.NORMAL:
				event_title = "Hyperspace";
				
				if is_goal_reached:
					event_text += "\nShip's data tells you that you've reached your destination. You now have to leave the Hyperspace."
				else:
					event_text = "You can choose whether to change the current Hyperspace level, or to stay on this one.";
				
				var ascent_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Go up one level");
				setup_event_signals(ascent_idx, course_chosen.bind(0), course_unchosen);
				
				var stay_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Stay on this level");
				setup_event_signals(stay_idx, course_chosen.bind(1), course_unchosen);
				
				var descent_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Go deeper");
				setup_event_signals(descent_idx, course_chosen.bind(2), course_unchosen);
			
			GameState.HyperspaceDepth.DEEP:
				event_title = "Hyperspace Depths";
				event_text = "It's probably a good idea to go up, if you can.";
				
				if is_goal_reached:
					event_text += "\nShip's data tells you that you've reached your destination. You now have to leave the Hyperspace."
				
				var ascent_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Go up one level");
				setup_event_signals(ascent_idx, course_chosen.bind(0), course_unchosen);
				
				var stay_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "Stay on this level");
				setup_event_signals(stay_idx, course_chosen.bind(1), course_unchosen);
	
	super._ready();
