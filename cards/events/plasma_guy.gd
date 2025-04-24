extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 4;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 4;
		GameState.HyperspaceDepth.NORMAL:
			damage = 8;
		GameState.HyperspaceDepth.DEEP:
			damage = 12;
	
	for i in 4:
		GameState.ship.take_electric_damage(
			GameState.ship.get_random_non_zero_hp_slot(), damage / 4
		);


func _init() -> void:
	
	event_image = preload("res://assets/graphics/events/ev_plasma.png");
	event_title = "A Plasma Incarnate";
	event_text = "He looks like a giant sphere of lighting, "\
		+ "and his movements hint on a will behind them. "\
		+ "Whatever he wants, you're in his way.";
