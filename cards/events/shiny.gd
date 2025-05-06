extends FlyEvent


var did : bool = false;


func do(_card) -> void:
	did = true;


func dond(_card) -> void:
	did = false;


func _action() -> void:
	if did:
		GameState.ingot_count += 1;
		var damage = 8;
		var target_system = GameState.ship.get_random_working_system_slot();
		GameState.ship.take_physical_damage(target_system, damage);
	
	did = false;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "A Mineral Rich Asteroid!";
	event_text = "Your ship's scanner picks up a strange signal. The adamantine you're transporting, "\
		+ "the asteroid's core is basically made from it! "\
		+ "You need, however, to slam your ship into the asteroid to get to it... "
	var idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "HAL, do it.");
	setup_event_signals(idx, do, dond);
	
	event_image = preload("res://assets/graphics/events/ev_rich_aster.png");
