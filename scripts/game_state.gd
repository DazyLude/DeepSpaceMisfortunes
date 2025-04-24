extends Node


signal new_phase(round_phase);

signal new_event(GenericEvent);

signal clear_tokens;
signal new_token(TokenType, RefCounted);
signal ping_tokens(TokenType);

signal system_repaired(int);
signal system_damaged(int);
signal system_manned;

signal ship_reset;

signal gameover(int);
signal victory(int);


enum HyperspaceDepth {
	NONE,
	SHALLOW,
	NORMAL,
	DEEP,
};


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
var travel_distance : float;
var hyper_depth : HyperspaceDepth;
var current_phase : RoundPhase;
var round_n : int = 0;
var score : int = 0;
var ingot_count : int = 0;

var active_table : Table = null;


var event_pools : Dictionary[HyperspaceDepth, EventPool] = {};
var interrupt_phase_sequence = null;

var life_support_failure : bool = false;


func get_score() -> int:
	return self.ingot_count * 3 - self.round_n;


func get_speed() -> float:
	var speed : float;
	
	match self.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			speed = 0.1;
		GameState.HyperspaceDepth.SHALLOW:
			speed = 0.5;
		GameState.HyperspaceDepth.NORMAL:
			speed = 2.0;
		GameState.HyperspaceDepth.DEEP:
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
		
		_ when travel_distance >= TRAVEL_GOAL and hyper_depth == HyperspaceDepth.NONE:
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
			new_event.emit(event_pools[hyper_depth].pull_random_event());
		
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
			
			round_n += 1;
		
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
	
	active_table = table;
	current_phase = RoundPhase.STARTUP;
	play_event.call_deferred(EventLoader.EventID.MAIN_MENU);
	reset_tokens.call_deferred();


func new_game() -> void:
	ship = ShipState.new();
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("OuterHull"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Hyperdrive"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Engines"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Autopilot"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("InnerHull"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("LifeSupport"));
	ship.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Navigation"));
	
	travel_distance = 0.0;
	hyper_depth = HyperspaceDepth.NONE;
	current_phase = RoundPhase.GAME_START;
	round_n = 0;
	score = 0;
	ingot_count = 10;
	life_support_failure = false;
	interrupt_phase_sequence = null;
	
	event_pools[HyperspaceDepth.NONE] = EventPool.get_space_pool();
	event_pools[HyperspaceDepth.SHALLOW] = EventPool.get_shallow_pool();
	event_pools[HyperspaceDepth.NORMAL] = EventPool.get_normal_pool();
	event_pools[HyperspaceDepth.DEEP] = EventPool.get_deep_pool();
	
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
