extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 1;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 2;
		GameState.HyperspaceDepth.NORMAL:
			damage = 4;
		GameState.HyperspaceDepth.DEEP:
			damage = 8;
	
	var is_navigation_ok_and_manned = GameState.ship.is_system_manned(GameStateClass.ShipState.System.NAVIGATION) \
		and GameState.ship.is_system_ok(GameStateClass.ShipState.System.NAVIGATION);
	
	if is_navigation_ok_and_manned:
		damage -= 1;
	
	damage = maxi(0, damage);
	
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.PHYSICAL, damage);


func _init() -> void:
	event_title = "An Asteroid Field";
	event_text = "A minor course correction might be needed.";
	event_image = preload("res://assets/graphics/events/ev_aster.png");
