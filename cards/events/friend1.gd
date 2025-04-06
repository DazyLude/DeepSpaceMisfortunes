extends GenericEvent


func _action() -> void:
	pass;


func _init() -> void:
	is_consumed = LimitedType.LIMITED_GLOBALLY;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "A Fellow Space Pirate";
	event_text = "Your ship's sensors pick up a friendly IFF codes. "\
		+ "It's you old pal, Sir Captain Jack Bebop (you've met once)! "\
		+ "You share a couple of stories with a bottle of space-rum. He's just finished a successful haul.";
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.FRIEND2);
	
	super._ready();
