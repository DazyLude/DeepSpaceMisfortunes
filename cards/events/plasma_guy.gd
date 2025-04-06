extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 3;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 3;
		GameState.HyperspaceDepth.NORMAL:
			damage = 6;
		GameState.HyperspaceDepth.DEEP:
			damage = 12;
	
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.ELECTRIC, damage / 3);
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.ELECTRIC, damage / 3);
	GameState.ship.take_damage_to_random_system(GameStateClass.ShipState.DamageType.PHYSICAL, damage / 3);


func _init() -> void:
	event_title = "A Plasma Incarnate";
	event_text = "He looks like a giant sphere of lighting, "\
		+ "and his movements hint on a will behind them. "\
		+ "Whatever he wants, you're in his way.";
