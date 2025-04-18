extends GenericEvent

var ingot_set : bool = false;
var nav_set : bool = false;


func set_ingot(_c) -> void:
	ingot_set = true;


func unset_ingot(_c) -> void:
	ingot_set = false;


func set_nav(_c) -> void:
	nav_set = true;


func unset_nav(_c) -> void:
	nav_set = false;


func go_next() -> void:
	if nav_set and ingot_set:
		GameState.play_event.call_deferred(GlobalEventPool.EventID.TUTORIAL_SYSTEMS);
	else:
		GameState.play_event.call_deferred(GlobalEventPool.EventID.TUTORIAL_TOKENS);
		
		if not ingot_set: GameState.ping_tokens.emit.call_deferred(Table.TokenType.INGOT);
		if not nav_set: GameState.ping_tokens.emit.call_deferred(Table.TokenType.SHIP_NAVIGATION);


func _action() -> void:
	pass;


func _prepare() -> void:
	reset_event_inputs();
	
	ingot_set = false;
	nav_set = false;
	
	GameState.ingot_count = 1;
	GameState.reset_tokens();
	
	event_title = "Tutorial: Tokens";
	event_text = "The game flow and event outcomes are controlled by dragging tokens to various inputs. The tokens are spawned in the bottom right part of the screen.\nTo continue, please fill inputs on this event card correctly.";
	
	var idx = setup_event_input(Table.TokenType.SHIP_NAVIGATION, "put navigation here");
	setup_event_signals(idx, set_nav, unset_nav);
	
	var idx2 = setup_event_input(Table.TokenType.INGOT, "put ingot here");
	setup_event_signals(idx2, set_ingot, unset_ingot);
	
	GameState.interrupt_phase_sequence = go_next;
	
	super._ready();
