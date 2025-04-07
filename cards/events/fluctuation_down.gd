extends GenericEvent


var did : bool = false;


func do(_card) -> void:
	did = true;


func dond(_card) -> void:
	did = false;

func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 1;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 1;
		GameState.HyperspaceDepth.NORMAL:
			damage = 3;
		GameState.HyperspaceDepth.DEEP:
			damage = 6;
	
	var target_system_1 = GameState.ship.get_random_working_system();
	var damage_1 = damage;
	var target_system_2 = GameState.ship.get_random_working_system();
	var damage_2 = damage;
	
	if GameState.ship.is_system_manned(target_system_1):
		damage_1 -= 1;
	if GameState.ship.is_system_manned(target_system_2):
		damage_2 -= 1;
	
	
	GameState.ship.take_electric_damage(target_system_1, damage_1);
	GameState.ship.take_electric_damage(target_system_2, damage_2);
	
	if GameState.hyper_depth < 3 and not did:
		GameState.hyper_depth += 1;


func _prepare() -> void:
	reset_event_inputs();
	
	did = false;
	
	var is_hyperdrive_ok = GameState.ship.is_system_ok(GameState.ShipState.System.HYPER_ENGINES);
	var is_navigation_ok_and_manned = GameState.ship.is_system_ok(GameState.ShipState.System.NAVIGATION)\
		and GameState.ship.is_system_manned(GameState.ShipState.System.NAVIGATION);
	
	event_title = "Hyperspace Fluctuation";
	event_text = "A Space-Time fluctuation of Hyperspace causes a system overload. "\
		+ "This one tries to pull you deeper in!";
	
	if is_hyperdrive_ok and is_navigation_ok_and_manned:
		event_text += "\nYou can attempt to stay where you are.";
		
		var idx = setup_event_input(Table.TokenType.SHIP_NAVIGATION, "fight it");
		setup_event_signals(idx, do, dond);
