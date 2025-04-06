extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 2;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 3;
		GameState.HyperspaceDepth.NORMAL:
			damage = 6;
		GameState.HyperspaceDepth.DEEP:
			damage = 12;
	
	if GameState.ship.is_system_manned(GameStateClass.ShipState.System.NAVIGATION):
		damage -= 2;
	
	damage = maxi(0, damage);
	
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.PHYSICAL, damage);


func _init() -> void:
	event_title = "A Large Asteroid Field";
	event_text = "This one is particularly large and dense. A course adjustment is required.";
