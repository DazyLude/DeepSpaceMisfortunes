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
			damage = 5;
	
	var target_system = GameState.ship.get_random_working_system();
	
	if GameState.ship.is_system_manned(target_system):
		damage -= 1;
	
	GameState.ship.take_electric_damage(target_system, damage);
	GameState.ship.take_physical_damage(target_system, damage);
	


func _init() -> void:
	event_title = "Cosmic Rays!";
	event_text = "An extremely concentrated beam of high energy particles scorches its way through your ship, burning electric systems.";
	event_image = preload("res://assets/graphics/events/ev_rays.png");
