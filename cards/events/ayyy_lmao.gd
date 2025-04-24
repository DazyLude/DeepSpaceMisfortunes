extends GenericEvent


var bribe : bool = false;


func bribed(_card) -> void:
	bribe = true;


func unbribed(_card) -> void:
	bribe = false;



func _action() -> void:
	if bribe:
		GameState.ingot_count -= 1;
	else:
		var damage = 4; # x2
		var target_system = GameState.ship.get_random_working_system_slot();
		GameState.ship.take_electric_damage(target_system, damage);
		target_system = GameState.ship.get_random_working_system_slot();
		GameState.ship.take_physical_damage(target_system, damage);
	
	bribe = false;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Aliens!";
	event_text = "These aliens are trying to board your ship! They're going to damage everything!";
	event_image = preload("res://assets/graphics/events/ev_ayy.png");
	
	var idx = setup_event_input(GameState.TokenType.INGOT, "please don't");
	setup_event_signals(idx, bribed, unbribed);
	
	super._ready();
