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
	
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.PHYSICAL, damage);


func _init() -> void:
	event_title = "An Asteroid";
	event_text = "A minor course correction might be needed.";
