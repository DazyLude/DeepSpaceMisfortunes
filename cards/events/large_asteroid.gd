extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		MapState.HyperspaceDepth.NONE:
			damage = 2;
		MapState.HyperspaceDepth.SHALLOW:
			damage = 3;
		MapState.HyperspaceDepth.NORMAL:
			damage = 6;
		MapState.HyperspaceDepth.DEEP:
			damage = 10;
	
	var is_navigation_ok_and_manned = GameState.ship.is_role_manned(ShipState.SystemRole.NAVIGATION) \
		and GameState.ship.is_role_ok(ShipState.SystemRole.NAVIGATION);
	
	if is_navigation_ok_and_manned:
		damage -= 1;
	
	damage = maxi(0, damage);
	
	GameState.ship.take_physical_damage(GameState.ship.get_random_non_zero_hp_slot(), damage);


func _init() -> void:
	event_title = "A Large Asteroid Field";
	event_text = "This one is particularly large and dense. A course adjustment is required.";
	event_image = preload("res://assets/graphics/events/ev_big_aster.png");
