extends GenericEvent


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
	
	var target_system_1 = GameState.ship.get_random_system();
	var damage_1 = damage;
	var target_system_2 = GameState.ship.get_random_system();
	var damage_2 = damage;
	
	if GameState.ship.is_system_manned(target_system_1):
		damage_1 -= 1;
	if GameState.ship.is_system_manned(target_system_2):
		damage_2 -= 1;
	
	
	GameState.ship.take_electric_damage(target_system_1, damage_1);
	GameState.ship.take_electric_damage(target_system_2, damage_2);
	
	if GameState.hyper_depth > 0:
		GameState.hyper_depth -= 1;


func _init() -> void:
	event_title = "Hyperspace Fluctuation";
	event_text = "A Space-Time fluctuation of Hyperspace causes a system overload. "\
		+ "It also tries to push you out of Hyperspace, back to the world where you belong.";
