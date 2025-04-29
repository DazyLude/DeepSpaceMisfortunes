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
	ENDGAME,
	GAME_START,
	
	REPAIRS,
	NAVIGATION,
	PLAY_EVENTS_QUEUE,
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

var move_command : MapState.MovementCommand = null;
var event_queue : Array[EventLoader.EventID] = [];
var callable_queue : Array[Callable] = [];

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
	match current_phase:
		_ when not callable_queue.is_empty():
			callable_queue.pop_front().call();
		
		_ when not event_queue.is_empty():
			play_event(event_queue.pop_front());
		
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
		
		RoundPhase.PLAY_EVENTS_QUEUE, RoundPhase.GAME_START:
			map.advance_rounds();
			global_round += 1;
			current_phase = RoundPhase.REPAIRS;
			run_repairs_phase();
		
		RoundPhase.REPAIRS:
			current_phase = RoundPhase.NAVIGATION;
			run_navigation_phase();
		
		RoundPhase.NAVIGATION:
			current_phase = RoundPhase.PLAY_EVENTS_QUEUE;
			run_events_phase();
	
	reset_tokens.call_deferred();
	new_phase.emit(current_phase);


func run_repairs_phase() -> void:
	ship.reset_crew();
	play_event(EventLoader.EventID.ASSIGN_REPAIRS);


func run_navigation_phase() -> void:
	self.move_command = null;
	play_event(EventLoader.EventID.SHIP_NAVIGATION);


func run_events_phase() -> void:
	ship.repair_systems();
	
	if not ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT) and life_support_failure:
		play_event(EventLoader.EventID.GAMEOVER);
	elif not ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT):
		life_support_failure = true;
	
	var scheduled_events := map.move_and_draw_scheduled_events(self.move_command);
	
	if ship.is_role_ok(ShipState.SystemRole.AUTOPILOT):
		scheduled_events.push_front(EventLoader.EventID.SHIP_ACTION);
	
	var random_event = map.pull_random_event();
	if random_event.is_ok():
		new_event.emit(random_event.unwrap());


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
	ship.rng_ref = self.rng;
	
	map = MapState.new(MapState.HyperspaceDepth.NONE, TRAVEL_GOAL);
	map.add_pool(MapState.HyperspaceDepth.NONE, PoolLibrary.get_event_pool_by_name("Space"));
	map.add_pool(MapState.HyperspaceDepth.SHALLOW, PoolLibrary.get_event_pool_by_name("Shallow"));
	map.add_pool(MapState.HyperspaceDepth.NORMAL, PoolLibrary.get_event_pool_by_name("Normal"));
	map.add_pool(MapState.HyperspaceDepth.DEEP, PoolLibrary.get_event_pool_by_name("Deep"));
	map.rng_ref = self.rng;
	
	current_phase = RoundPhase.GAME_START;
	global_round = 0;
	score = 0;
	ingot_count = 10;
	life_support_failure = false;
	
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
