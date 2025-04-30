extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.take_electric_damage(ShipState.SystemRole.ENGINES, 2);
	GameState.ship.take_electric_damage(ShipState.SystemRole.NAVIGATION, 2);
	
	event_title = "Electric Damage";
	event_text = "I called my buddy, Zeus, to throw a lighting at your ship. He targeted engines and navigation. Electric damage bypasses the ship's Outer Hull, but the Inner Hull absorbs it, if it's HP is more than zero. Navigation and Life Support are protected by the Inner Hull.";
	
	GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_DAMAGE_NORMAL);
	
	super._ready();
