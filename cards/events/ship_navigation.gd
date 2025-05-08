extends FlyEvent


@onready var inputs := [$Up, $Forward, $Backward, $Down];


func depth_chosen(_card, which: int) -> void:
	var depth_value := GameState.map.layer as int + which;
	depth_value = clampi(depth_value, 0, 3);
	var speed = GameState.get_speed(depth_value);
	var direction = 0;
	
	var command = MapState.MovementCommand.new(speed, direction, depth_value);
	
	GameState.prepare_new_movement_command(command);


func depth_unchosen(_card) -> void:
	depth_chosen(_card, 0);


func direction_chosen(_card, which: int) -> void:
	var direction = which;
	
	var depth_value := GameState.map.layer;
	var speed = GameState.get_speed(GameState.map.layer);
	
	var command = MapState.MovementCommand.new(speed, direction, depth_value);
	
	GameState.prepare_new_movement_command(command);


func direction_unchosen(_card) -> void:
	direction_chosen(_card, 0);


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_rows.resize(4);
	
	# up/down movement
	var are_drives_ok = GameState.ship.is_role_ok(ShipState.SystemRole.HYPERDRIVE);
	
	# forward/backward
	var are_engines_ok = GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES);
	var is_nav_ok = GameState.ship.is_role_ok(ShipState.SystemRole.NAVIGATION);
	
	match [are_drives_ok, are_engines_ok, is_nav_ok]:
		[true, true, true]: # everything good
			event_image = preload("res://assets/graphics/events/ev_navigat.png");
			event_title = "Choose Ship's Course";
			event_text = "Choose where to move your ship."
			
			var up_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[up_idx] = $Up;
			setup_event_signals(up_idx, depth_chosen.bind(-1), depth_unchosen);
			
			var down_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[down_idx] = $Down;
			setup_event_signals(down_idx, depth_chosen.bind(1), depth_unchosen);
			
			var forward_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[forward_idx] = $Forward;
			setup_event_signals(forward_idx, direction_chosen.bind(1), direction_unchosen);
			
			var backward_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[backward_idx] = $Backward;
			setup_event_signals(backward_idx, direction_chosen.bind(-1), direction_unchosen);
			
		[_, _, false]: # navigation busted
			event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
			event_title = "Navigation is out!";
			event_text = "You can't control your ship if the controls are busted."
		[false, false, _]: # everything not good
			event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
			event_title = "Everything is on fire!";
			event_text = "You can't control your ship if there is nothing to control."
			
		[true, false, _]: # hyperspace change ok
			event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
			event_title = "Hyper Drive is out!";
			event_text = "You can't manually change the Hyperspace level when the Hyper Drive is out of commission. Your engines are working, at least."
			
			var up_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[up_idx] = $Up;
			setup_event_signals(up_idx, depth_chosen.bind(-1), depth_unchosen);
			
			var down_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[down_idx] = $Down;
			setup_event_signals(down_idx, depth_chosen.bind(1), depth_unchosen);
			
		[false, true, _]: # normal movement ok
			event_image = preload("res://assets/graphics/events/ev_navigat_crossed.png");
			event_title = "Hyper Drive is out!";
			event_text = "You can't manually change the Hyperspace level when the Hyper Drive is out of commission. Your engines are working, at least."
			
			var forward_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[forward_idx] = $Forward;
			setup_event_signals(forward_idx, direction_chosen.bind(1), direction_unchosen);
			
			var backward_idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "");
			event_rows[backward_idx] = $Backward;
			setup_event_signals(backward_idx, direction_chosen.bind(-1), direction_unchosen);
	
	for input in inputs:
		if input not in event_rows:
			input.hide();
	
