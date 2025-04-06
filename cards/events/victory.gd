extends GenericEvent


var is_token_set : bool = false;


func set_token(_card) -> void:
	is_token_set = true;


func unset_token(_card) -> void:
	is_token_set = false;



func _action() -> void:
	if is_token_set:
		GameState.new_game(GameState.active_table);


func _prepare() -> void:
	reset_event_inputs();
	
	GameState.clear_tokens.emit();
	GameState.new_token.emit(Table.TokenType.SHIP_NAVIGATION);
	
	event_title = "Victory!";
	event_text = "Congratulations, you've won!\n"
	event_text += "Your score is... %d!\n" % (GameState.ingot_count * 3 - GameState.round_n);
	event_text += "Score increases with the ingot count, and decreases with rounds spent. Maybe another try? :)"
	event_text += "\n\nThank you for playing!"
	
	GameState.interrupt_phase_sequence = GameState.play_event.bind(GlobalEventPool.EventID.VICTORY);
	
	var idx = setup_event_input(Table.TokenType.SHIP_NAVIGATION, "start new game");
	setup_event_signals(idx, set_token, unset_token);
	
	super._ready();
