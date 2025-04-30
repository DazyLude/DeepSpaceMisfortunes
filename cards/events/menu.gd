extends GenericEvent


var new_game_selected : bool = false;
var tutorial_selected : bool = false;


func set_token(_card) -> void:
	new_game_selected = true;


func set_tutorial_token(_c) -> void:
	tutorial_selected = true;


func unset_token(_card) -> void:
	new_game_selected = false;
	tutorial_selected = false;


func _go_next() -> void:
	if new_game_selected:
		GameState.new_game();
		GameState.clear_tokens.emit();
	elif tutorial_selected:
		GameState.clear_tokens.emit();
		GameState.add_event_to_queue(EventLoader.EventID.TUTORIAL_INTRO);
		GameState.advance_phase();
	else:
		GameState.add_event_to_queue(EventLoader.EventID.MAIN_MENU);
		GameState.advance_phase();


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	unset_token(null);
	
	event_title = "Deep Space Misfortunes";
	event_text = "You are a Space Pirate. "\
		+ "Your goal is to carry a contraband cargo of 10 admantine ingots "\
		+ "through the unforgiving cold vastness of Space.\nGood luck!"
	
	var idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "start a new game");
	setup_event_signals(idx, set_token, unset_token);
	
	var idx2 = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "play the tutorial");
	setup_event_signals(idx2, set_tutorial_token, unset_token);
	
	GameState.add_callable_to_queue(_go_next);
	
	super._ready();
