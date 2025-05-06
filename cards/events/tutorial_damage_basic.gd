extends FlyEvent

var block : bool = false;

func go_next() -> void:
	if block:
		return;
	block = true;
	
	GameState.ship.repair_systems();
	var damage_left = GameState.ship.get_total_damage();
	
	block = false;
	
	if damage_left == 0:
		GameState.play_event.call_deferred(EventLoader.EventID.TUTORIAL_GAME_PROGRESSION);
	else:
		GameState.ship.full_repair();
		GameState.play_event.call_deferred(EventLoader.EventID.TUTORIAL_DAMAGE_BASIC);
		GameState.ship.reset_crew();


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	block = false;
	
	GameState.ship = ShipState.new();
	GameState.ingot_count = 0;
	
	GameState.ship.ships_crew.clear();
	GameState.ship.ships_crew[ShipState.Crewmate.new()] = -1;
	GameState.ship.ships_crew[ShipState.Crewmate.new()] = -1;
	GameState.ship.take_physical_damage(0, 2);
	
	GameState.reset_tokens();
	
	event_title = "Tutorial: Damage";
	event_text = "I've thrown an asteroid at you ship, to damage it. Whatever I was aiming at, the hull blocked it. Now you can repair it.\nTo repair the system, put a crewmember in it. If the system is severely damaged, you can use more than one crew member, and they will work together.\nRepair the outer hull to full hp to continue.";
	
	GameState.add_callable_to_queue(go_next);
