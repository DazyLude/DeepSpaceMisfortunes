extends GenericEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.ship.take_physical_damage(GameState.ShipState.System.LIFE_SUPPORT, 12);
	
	event_title = "Normal Damage";
	event_text = "I threw a large asteroid at your ships Life Support. Physical sources of damage have to penetrate the hull to deal damage, but if they do, they will damage both the hull, and the targeted system.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(EventLoader.EventID.TUTORIAL_END);
	
	super._ready();
