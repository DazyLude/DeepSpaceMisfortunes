extends Node


signal new_phase(round_phase);

signal new_event(Node2D);

signal clear_tokens;
signal new_token(TokenType, RefCounted);
signal ping_tokens(TokenType);

signal system_repaired(int);
signal system_damaged(int);
signal system_manned;

signal ship_reset;

signal gameover(int);
signal victory(int);


enum RoundPhase {
	STARTUP,
	TUTORIAL,
	
	GAME_START,
	PREPARATION,
	EXECUTION,
	EVENT,
	SHIP_ACTION,
	ENDGAME,
};


enum TokenType {
	CREWMATE,
	INGOT,
	SHIP_NAVIGATION,
	OTHER,
}


const TRAVEL_GOAL : float = 22.0;
const GAMEOVER_PENALTY : int = 30;


var rng := RandomNumberGenerator.new();


var ship : ShipState;
var map : MapState;

var global_round : int = 0;
var current_phase : RoundPhase;

var score : int = 0;
var ingot_count : int = 0;

var active_table : Table = null;


var event_pools : Dictionary[MapState.HyperspaceDepth, EventPool] = {};
var interrupt_phase_sequence = null;

var life_support_failure : bool = false;


func get_score() -> int:
	return self.ingot_count * 3 - self.global_round;


func get_speed() -> float:
	var speed : float;
	
	match self.map.layer:
		MapState.HyperspaceDepth.NONE:
			speed = 0.1;
		MapState.HyperspaceDepth.SHALLOW:
			speed = 0.5;
		MapState.HyperspaceDepth.NORMAL:
			speed = 2.0;
		MapState.HyperspaceDepth.DEEP:
			speed = 5.0;
	
	return speed;


func reset_tokens() -> void:
	clear_tokens.emit();
	
	for crewmate in ship.get_free_crewmates():
		new_token.emit(GameState.TokenType.CREWMATE, crewmate);
	
	for ingot_i in ingot_count:
		new_token.emit(GameState.TokenType.INGOT, null);
	
	new_token.emit(GameState.TokenType.SHIP_NAVIGATION, null);


func advance_phase() -> void:
	var should_interrupt : bool = interrupt_phase_sequence != null \
		and typeof(interrupt_phase_sequence) == TYPE_CALLABLE;
	
	match current_phase:
		RoundPhase.STARTUP when active_table.current_event.new_game_selected:
			new_game();
			new_event.emit(null);
			clear_tokens.emit();
		
		RoundPhase.STARTUP when active_table.current_event.tutorial_selected:
			current_phase = RoundPhase.TUTORIAL;
			new_event.emit(null);
			play_event(EventLoader.EventID.TUTORIAL_INTRO);
		
		RoundPhase.STARTUP:
			active_table.display_hint();
			return;
		
		RoundPhase.ENDGAME when active_table and active_table.current_event and active_table.current_event.is_token_set:
			new_game();
			new_event.emit(null);
			clear_tokens.emit();
		
		RoundPhase.ENDGAME when active_table and active_table.current_event and active_table.current_event.is_token_set2:
			go_to_menu(active_table);
			new_event.emit(null);
			clear_tokens.emit();
		
		_ when map.is_at_finish_wrong_layer():
			clear_tokens.emit();
			play_event(EventLoader.EventID.VICTORY);
		
		_ when should_interrupt:
			interrupt_phase_sequence.call_deferred();
			interrupt_phase_sequence = null;
		
		RoundPhase.SHIP_ACTION, RoundPhase.GAME_START:
			current_phase = RoundPhase.PREPARATION;
			ship.reset_crew();
			play_event(EventLoader.EventID.SHIP_NAVIGATION);
		
		RoundPhase.PREPARATION when active_table.current_event._can_play():
			current_phase = RoundPhase.EXECUTION;
			
			ship.repair_systems();
			play_event(EventLoader.EventID.PROGRESS_REPORT);
		
		RoundPhase.PREPARATION:
			ping_tokens.emit(GameState.TokenType.SHIP_NAVIGATION);
			return;
		
		RoundPhase.EXECUTION:
			current_phase = RoundPhase.EVENT;
			new_event.emit(map.pull_random_event().unwrap());
		
		RoundPhase.EVENT when active_table.current_event._can_play():
			current_phase = RoundPhase.SHIP_ACTION;
			
			if not ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT) and life_support_failure:
				play_event(EventLoader.EventID.GAMEOVER);
			elif not ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT):
				life_support_failure = true;
				play_event(EventLoader.EventID.SHIP_ACTION);
			else:
				life_support_failure = false;
				play_event(EventLoader.EventID.SHIP_ACTION);
			
			map.advance_rounds();
			global_round += 1;
		
		RoundPhase.EVENT:
			ping_tokens.emit(GameState.TokenType.SHIP_NAVIGATION);
			ping_tokens.emit(GameState.TokenType.INGOT);
			return;
	
	reset_tokens.call_deferred();
	new_phase.emit(current_phase);


func play_event(id: EventLoader.EventID) -> void:
	new_event.emit(EventLoader.get_event_instance(id));


func go_to_menu(table: Table) -> void:
	ship = ShipState.new();
	map = MapState.new(MapState.HyperspaceDepth.NONE, TRAVEL_GOAL);
	
	active_table = table;
	current_phase = RoundPhase.STARTUP;
	play_event.call_deferred(EventLoader.EventID.MAIN_MENU);
	reset_tokens.call_deferred();


func new_game() -> void:
	ship = ShipLibrary.get_ship_by_name("Standard");
	map = MapState.new(MapState.HyperspaceDepth.NONE, TRAVEL_GOAL);
	map.add_pool(MapState.HyperspaceDepth.NONE, PoolLibrary.get_event_pool_by_name("Space"));
	map.add_pool(MapState.HyperspaceDepth.SHALLOW, PoolLibrary.get_event_pool_by_name("Shallow"));
	map.add_pool(MapState.HyperspaceDepth.NORMAL, PoolLibrary.get_event_pool_by_name("Normal"));
	map.add_pool(MapState.HyperspaceDepth.DEEP, PoolLibrary.get_event_pool_by_name("Deep"));
	
	current_phase = RoundPhase.GAME_START;
	global_round = 0;
	score = 0;
	ingot_count = 10;
	life_support_failure = false;
	interrupt_phase_sequence = null;
	
	#event_pools[HyperspaceDepth.NONE] = EventPool.get_test_pool();
	#event_pools[HyperspaceDepth.SHALLOW] = EventPool.get_test_pool();
	
	advance_phase.call_deferred();


class OtherToken extends RefCounted:
	var token_type : GameState.TokenType;
	
	
	static func get_nav_token() -> OtherToken:
		var token = new();
		token.token_type = GameState.TokenType.SHIP_NAVIGATION;
		return token;
	
	
	static func get_ingot_token() -> OtherToken:
		var token = new();
		token.token_type = GameState.TokenType.INGOT;
		return token;
