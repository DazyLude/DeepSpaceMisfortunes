extends FlyEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.take_physical_damage(ShipState.SystemRole.LIFE_SUPPORT, 12);
	
	event_title = "Normal Damage";
	event_text = "I threw a large asteroid at your ships Life Support. Physical sources of damage have to penetrate the hull to deal damage, but if they do, they will damage both the hull, and the targeted system.";
	
	GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_END);
