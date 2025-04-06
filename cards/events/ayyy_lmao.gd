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
		var damage = 3;
		var target_system = GameState.ship.get_random_working_system();
		GameState.ship.take_physical_damage(target_system, damage);
		GameState.ship.take_electric_damage(target_system, damage);
	
	bribe = false;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Aliens!";
	event_text = "These aliens are boarding your ship! They're going to damage your ship!"
	
	var idx = setup_event_input(Table.TokenType.INGOT, "Please don't");
	setup_event_signals(idx, bribed, unbribed);
	
	super._ready();
