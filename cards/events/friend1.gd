extends FlyEvent


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "A Fellow Space Pirate";
	event_text = "Your ship's sensors pick up a friendly IFF codes. "\
		+ "It's you old pal, Sir Captain Jack Bebop (you've met once)! "\
		+ "You share a couple of stories with a bottle of space-rum. He's just finished a successful haul.";
	event_image = preload("res://assets/graphics/events/ev_pirate.png");
	
	GameState.add_event_to_queue(EventLoader.EventID.FRIEND2);
	
	super._ready();
