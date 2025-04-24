extends GenericEvent


var is_token_set : bool = false;
var is_token_set2 : bool = false;


func set_token(_card) -> void:
	is_token_set = true;


func set_token2(_card) -> void:
	is_token_set2 = true;


func unset_token(_card) -> void:
	is_token_set = false;
	is_token_set2 = false;


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	event_image = preload("res://assets/graphics/events/ev_police.png");
	event_title = "Game Over...";
	event_text = "The infinite coldness of cosmos has consumed you and your ship.\n"
	event_text += "Your score is... %d!\n" % (GameState.get_score() - GameState.GAMEOVER_PENALTY);
	event_text += "Score increases with the ingot count, and decreases with rounds spent. Maybe another try? :)";
	
	GameState.current_phase = GameState.RoundPhase.ENDGAME;
	
	var idx = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "start new game");
	setup_event_signals(idx, set_token, unset_token);
	var idx2 = setup_event_input(GameState.TokenType.SHIP_NAVIGATION, "to the menu");
	setup_event_signals(idx2, set_token2, unset_token);
	
	super._ready();
