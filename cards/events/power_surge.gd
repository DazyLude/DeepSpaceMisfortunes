extends FlyEvent


func _action() -> void:
	var damage : int;
	
	match GameState.map.layer:
		MapState.HyperspaceDepth.NONE:
			damage = 4;
		MapState.HyperspaceDepth.SHALLOW:
			damage = 4;
		MapState.HyperspaceDepth.NORMAL:
			damage = 8;
		MapState.HyperspaceDepth.DEEP:
			damage = 12;
	
	var target_system = GameState.ship.get_random_working_system_slot();
	
	if GameState.ship.is_role_manned(target_system):
		damage -= 2;
	
	damage = maxi(0, damage);
	
	GameState.ship.take_electric_damage(target_system, damage / 2);
	GameState.ship.take_electric_damage(target_system, damage / 2);


func _init() -> void:
	event_title = "Power Surge!";
	event_text = "A strong electromagnetic pulse catches your ship. Ship's electronics are protected, but it might be not enough for a beam of such intensity.";
	event_image = preload("res://assets/graphics/events/ev_power.png");
	
