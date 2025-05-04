extends FlyEvent


const damage_threshold : int = 10;


func _action() -> void:
	var move_command = MapState.MovementCommand.new(-3.0, 1, GameState.map.layer);
	GameState.map.free_move(move_command);


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Space Police";
	event_image = preload("res://assets/graphics/events/ev_progress.png");
	event_text = "You get escorted a bit to where you came from, but make a lucky break and escape.";
	
	
	super._ready();
