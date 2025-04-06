extends GenericEvent


func _action() -> void:
	var damage : int;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			damage = 1;
		GameState.HyperspaceDepth.SHALLOW:
			damage = 1;
		GameState.HyperspaceDepth.NORMAL:
			damage = 2;
		GameState.HyperspaceDepth.DEEP:
			damage = 4;
	
	var target_system = GameState.ship.get_random_working_system();
	
	GameState.ship.take_electric_damage(target_system, damage);
	
	if GameState.ship.is_system_manned(target_system):
		damage -= 1;
	
	GameState.ship.take_physical_damage(target_system, damage);


func _init() -> void:
	event_title = "Cosmic Rays!";
	event_text = "You're is space, of course there are cosmic rays of high energy particles "\
		+ "that want to irradiate you specifically.";
