extends Node


signal new_phase(round_phase);

# ATTENTION
# current implementation may cause memory leaks in the form of orphaned nodes:
# node is instanced here, then it's reference is signalled and released.
# This leaves an orphan Node2D (GenericEvent) node, if it wasn't picked by table.
# Currently there is always a singular (!) Table node
# (multiple table nodes may cause issues as well with dangling pointers)
# that picks up this reference, and then frees it when the event is over.
signal new_event(Node2D);
signal new_ship(ShipState);
signal new_move_command;
signal new_map;

signal clear_tokens;
signal new_token(TokenType, RefCounted);
signal ping_tokens(TokenType);


enum RoundPhase {
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

var move_command : MapState.MovementCommand = null;

var event_queue : Array[EventLoader.EventID] = [];
var callable_queue : Array[Callable] = [];
var event_instance_queue : Array[Node2D] = [];

var life_support_failure : bool = false;


func get_score() -> int:
	return self.ingot_count * 3 - self.global_round;


func get_speed(layer: MapState.HyperspaceDepth) -> float:
	var speed : float;
	
	match layer:
		MapState.HyperspaceDepth.NONE:
			speed = 0.1;
		MapState.HyperspaceDepth.SHALLOW:
			speed = 0.5;
		MapState.HyperspaceDepth.NORMAL:
			speed = 2.0;
		MapState.HyperspaceDepth.DEEP:
			speed = 5.0;
	
	if not GameState.ship.is_role_ok(ShipState.SystemRole.ENGINES):
		speed = 0;
	
	if not GameState.ship.is_role_ok(ShipState.SystemRole.NAVIGATION):
		speed /= 2;
	
	return speed;


func reset_tokens() -> void:
	clear_tokens.emit();
	
	if ship != null:
		for crewmate in ship.get_free_crewmates():
			new_token.emit(GameState.TokenType.CREWMATE, crewmate);
	
	for ingot_i in ingot_count:
		new_token.emit(GameState.TokenType.INGOT, null);
	
	new_token.emit(GameState.TokenType.SHIP_NAVIGATION, null);


func advance_phase() -> void:
	match current_phase:
		_ when not event_instance_queue.is_empty():
			new_event.emit(event_instance_queue.pop_back());
		
		_ when not callable_queue.is_empty():
			callable_queue.pop_back().call();
		
		_ when not event_queue.is_empty():
			play_event(event_queue.pop_back());
		
		RoundPhase.PLAY_EVENTS_QUEUE:
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


func prepare_new_movement_command(command: MapState.MovementCommand) -> void:
	move_command = command;
	new_move_command.emit();


func add_event_to_queue(event_id: EventLoader.EventID) -> void:
	event_queue.push_back(event_id);


func add_callable_to_queue(callable: Callable) -> void:
	callable_queue.push_back(callable);


func add_to_event_instance_queue(event: Node2D) -> void:
	event_instance_queue.push_back(event);


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
		return;
	elif not ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT):
		life_support_failure = true;
	
	var scheduled_events := map.move_and_draw_scheduled_events(self.move_command);
	self.move_command = null;
	
	if not map.is_at_exit():
		if ship.is_role_ok(ShipState.SystemRole.AUTOPILOT):
			add_event_to_queue(EventLoader.EventID.SHIP_ACTION);
		
		var random_event = map.pull_random_event();
		if random_event.is_ok():
			var event = random_event.unwrap();
			add_to_event_instance_queue(event);
	
	self.event_queue.append_array(scheduled_events);
	advance_phase();


func play_event(id: EventLoader.EventID) -> void:
	new_event.emit(EventLoader.get_event_instance(id));


func load_map() -> void:
	map = MapState.new(MapState.HyperspaceDepth.NONE, TRAVEL_GOAL);
	map.add_pool(MapState.HyperspaceDepth.NONE, PoolLibrary.get_event_pool_by_name("Space"));
	map.add_pool(MapState.HyperspaceDepth.SHALLOW, PoolLibrary.get_event_pool_by_name("Shallow"));
	map.add_pool(MapState.HyperspaceDepth.NORMAL, PoolLibrary.get_event_pool_by_name("Normal"));
	map.add_pool(MapState.HyperspaceDepth.DEEP, PoolLibrary.get_event_pool_by_name("Deep"));
	map.rng_ref = self.rng;
	
	map.add_exit(MapState.HyperspaceDepth.NONE, EventLoader.EventID.DEFAULT_CITY);
	map.add_exit(MapState.HyperspaceDepth.NONE, EventLoader.EventID.DEFAULT_CITY, false);
	
	new_map.emit();


func go_to_menu() -> void:
	new_ship.emit(null);
	new_map.emit();
	
	current_phase = RoundPhase.PLAY_EVENTS_QUEUE;
	
	play_event.call_deferred(EventLoader.EventID.MAIN_MENU);
	reset_tokens.call_deferred();


func new_game() -> void:
	ship = ShipLibrary.get_ship_by_name("Standard");
	ship.rng_ref = self.rng;
	new_ship.emit(ship);
	
	load_map();
	
	current_phase = RoundPhase.PLAY_EVENTS_QUEUE;
	global_round = 0;
	score = 0;
	ingot_count = 10;
	life_support_failure = false;
	
	event_queue.clear();
	callable_queue.clear();
	
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
