extends GenericEvent


var gave_bribe : bool = false;
var went_with : bool = false;


func give(_d) -> void:
	gave_bribe = true;


func leave(_d) -> void:
	went_with = true;


func dond(_d) -> void:
	went_with = false;
	gave_bribe = false;


func _can_play() -> bool:
	var can = gave_bribe or went_with;
	
	if not can:
		GameState.ping_tokens.emit.call_deferred(Table.TokenType.SHIP_NAVIGATION);
	
	return can;


func _go_next() -> void:
	if gave_bribe:
		GameState.play_event.call_deferred(GlobalEventPool.EventID.COSMOCOP2);
	elif went_with:
		GameState.play_event.call_deferred(GlobalEventPool.EventID.COSMOCOP3);
	else:
		GameState.play_event.call_deferred(GlobalEventPool.EventID.COSMOCOP);



func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_title = "Space Police";
	event_text = "\"Hello there, citizen!\" - a space cop pulls you over. A drop of sweat runs down your face. Space cop looks at your ship's cargo bay, as if he can see it contents right through...";
	event_image = preload("res://assets/graphics/events/ev_police.png");
	
	var idx1 = setup_event_input(Table.TokenType.SHIP_NAVIGATION, "bribe him");
	setup_event_signals(idx1, give, dond);
	
	var idx2 = setup_event_input(Table.TokenType.SHIP_NAVIGATION, "go with him");
	setup_event_signals(idx2, leave, dond);
	
	GameState.interrupt_phase_sequence = _go_next;
	
	super._ready();
