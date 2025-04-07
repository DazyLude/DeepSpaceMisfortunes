extends Node
class_name GameStateClass


signal new_phase(round_phase);

signal new_event(GenericEvent);

signal clear_tokens;
signal new_token(TokenType, RefCounted);
signal ping_tokens(TokenType);

signal system_repaired(System);
signal system_damaged(System);
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


const TRAVEL_GOAL : float = 20.0;
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
	return GameState.ingot_count * 3 - GameState.round_n;


func get_speed() -> float:
	var speed : float;
	
	match GameState.hyper_depth:
		GameState.HyperspaceDepth.NONE:
			speed = 0.1;
		GameState.HyperspaceDepth.SHALLOW:
			speed = 0.4;
		GameState.HyperspaceDepth.NORMAL:
			speed = 1.2;
		GameState.HyperspaceDepth.DEEP:
			speed = 3.0;
	
	return speed;


func reset_tokens() -> void:
	clear_tokens.emit();
	
	for crewmate in ship.ships_crew: # idle crewmembers
		if ship.ships_crew[crewmate] == ShipState.System.OTHER:
			new_token.emit(Table.TokenType.CREWMATE, crewmate);
	
	for ingot_i in ingot_count:
		new_token.emit(Table.TokenType.INGOT, null);
	
	new_token.emit(Table.TokenType.SHIP_NAVIGATION, null);


func advance_phase() -> void:
	var should_interrupt : bool = interrupt_phase_sequence != null \
		and typeof(interrupt_phase_sequence) == TYPE_CALLABLE;
	
	match current_phase:
		RoundPhase.STARTUP when active_table.current_event.new_game_selected:
			active_table.hide_hint();
			new_game();
			new_event.emit(null);
			clear_tokens.emit();
		
		RoundPhase.STARTUP when active_table.current_event.tutorial_selected:
			active_table.hide_hint();
			current_phase = RoundPhase.TUTORIAL;
			new_event.emit(null);
			play_event(GlobalEventPool.EventID.TUTORIAL);
		
		RoundPhase.STARTUP:
			new_event.emit(null);
			play_event(GlobalEventPool.EventID.MAIN_MENU);
			active_table.display_hint();
		
		RoundPhase.ENDGAME when active_table.current_event.is_token_set:
			new_game();
			new_event.emit(null);
			clear_tokens.emit();
		
		_ when travel_distance >= TRAVEL_GOAL and hyper_depth == HyperspaceDepth.NONE:
			clear_tokens.emit();
			play_event(GlobalEventPool.EventID.VICTORY);
		
		_ when should_interrupt:
			interrupt_phase_sequence.call_deferred();
			interrupt_phase_sequence = null;
		
		RoundPhase.SHIP_ACTION, RoundPhase.GAME_START:
			current_phase = RoundPhase.PREPARATION;
			ship.reset_crew();
			new_event.emit(null);
			play_event(GlobalEventPool.EventID.SHIP_NAVIGATION);
		
		RoundPhase.PREPARATION when active_table.current_event._can_play():
			current_phase = RoundPhase.EXECUTION;
			new_event.emit(null);
			
			clear_tokens.emit();
			ship.repair_systems();
			play_event(GlobalEventPool.EventID.PROGRESS_REPORT);
		
		RoundPhase.EXECUTION:
			current_phase = RoundPhase.EVENT;
			new_event.emit(null);
			new_event.emit(event_pools[hyper_depth].pull_random_event());
		
		RoundPhase.EVENT when active_table.current_event._can_play():
			current_phase = RoundPhase.SHIP_ACTION;
			new_event.emit(null);
			
			if not ship.is_system_ok(ShipState.System.LIFE_SUPPORT) and life_support_failure:
				play_event(GlobalEventPool.EventID.GAMEOVER);
			elif not ship.is_system_ok(ShipState.System.LIFE_SUPPORT):
				life_support_failure = true;
				play_event(GlobalEventPool.EventID.SHIP_ACTION);
			else:
				life_support_failure = false;
				play_event(GlobalEventPool.EventID.SHIP_ACTION);
			
			round_n += 1;
	
	reset_tokens.call_deferred();
	new_phase.emit(current_phase);


func play_event(id: GlobalEventPool.EventID) -> void:
	new_event.emit(GlobalEventPool.get_event_instance(id));


func go_to_menu(table: Table) -> void:
	ship = ShipState.new();
	ship.ships_crew.clear();
	
	active_table = table;
	current_phase = RoundPhase.STARTUP;
	play_event.call_deferred(GlobalEventPool.EventID.MAIN_MENU);
	reset_tokens.call_deferred();


func new_game() -> void:
	ship = ShipState.new();
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


class ShipState extends RefCounted:
	enum System {
		LIFE_SUPPORT,
		NAVIGATION,
		INNER_HULL,
		ENGINES,
		HYPER_ENGINES,
		AUTOPILOT,
		OUTER_HULL,
		OTHER,
	};
	
	enum DamageType {
		PHYSICAL,
		ELECTRIC,
	};
	
	const default_crew_count : int = 3;
	const default_hp : Dictionary[System, int] = {
		System.LIFE_SUPPORT: 1,
		System.NAVIGATION: 1,
		System.INNER_HULL: 3,
		System.ENGINES: 1,
		System.HYPER_ENGINES: 1,
		System.AUTOPILOT: 1,
		System.OUTER_HULL: 5,
	};
	
	var system_hp : Dictionary[System, int] = {};
	var ships_crew : Dictionary[Crewmate, System] = {};
	
	
	func get_total_damage() -> int:
		var total : int = 0;
		
		for system in default_hp:
			total += default_hp[system] - system_hp[system];
		
		return total;
	
	
	func take_physical_damage(system: System, damage: int) -> void:
		match system:
			_ when system_hp[System.OUTER_HULL] > 0:
				var hull_hp = system_hp[System.OUTER_HULL];
				if hull_hp > damage:
					system_hp[System.OUTER_HULL] -= damage;
					GameState.system_damaged.emit(System.OUTER_HULL);
				else:
					damage -= hull_hp;
					system_hp[System.OUTER_HULL] = 0;
					GameState.system_damaged.emit(System.OUTER_HULL);
					take_physical_damage(system, damage);
			
			System.LIFE_SUPPORT, System.NAVIGATION when system_hp[System.INNER_HULL] > 0:
				var hull_hp = system_hp[System.INNER_HULL];
				if hull_hp > damage:
					system_hp[System.INNER_HULL] -= damage;
					GameState.system_damaged.emit(System.INNER_HULL);
				elif hull_hp > 0:
					damage -= hull_hp;
					system_hp[System.INNER_HULL] = 0;
					GameState.system_damaged.emit(System.INNER_HULL);
					take_physical_damage(system, damage);
			_:
				system_hp[system] -= damage;
				GameState.system_damaged.emit(system);
	
	
	func take_electric_damage(system: System, damage: int) -> void:
		match system:
			System.LIFE_SUPPORT, System.NAVIGATION when is_system_ok(System.INNER_HULL):
				system_hp[System.INNER_HULL] -= damage;
				GameState.system_damaged.emit(System.INNER_HULL);
			_:
				system_hp[system] -= damage;
				GameState.system_damaged.emit(system);
		
	
	
	func get_random_working_system() -> System:
		var systems = system_hp.keys().filter(is_system_ok);
		return GameState.rng.randi_range(0, systems.size() - 1) as System;
	
	
	func take_damage_to_random_system(damage_type: DamageType, value: int) -> void:
		var system : System = get_random_working_system();
		
		match damage_type:
			DamageType.PHYSICAL:
				take_physical_damage(system, value);
			DamageType.ELECTRIC:
				take_electric_damage(system, value);
	
	
	func repair_system(system: System, to_full: bool = false) -> void:
		if not system_hp.has(system):
			return;
		
		if to_full:
			system_hp[system] = default_hp[system];
		
		else:
			if system_hp[system] < 0:
				system_hp[system] += 1;
			
			system_hp[system] += 1;
			system_hp[system] = mini(system_hp[system], default_hp[system]);
		
		GameState.system_repaired.emit(system);
	
	
	func repair_systems() -> void:
		for crewmate in ships_crew:
			repair_system(ships_crew[crewmate], true);
	
	
	func full_repair() -> void:
		for system in System.values():
			repair_system(system, true);
	
	
	func reset_crew() -> void:
		for mate in ships_crew:
			ships_crew[mate] = System.OTHER;
		
		GameState.system_manned.emit();
	
	
	func man_system(mate: Crewmate, system: System) -> void:
		if mate in ships_crew:
			ships_crew[mate] = system;
		else:
			push_error("impostor amongus");
		
		GameState.system_manned.emit();
	
	
	func stop_manning(mate: Crewmate) -> void:
		if mate in ships_crew:
			ships_crew[mate] = System.OTHER;
		else:
			push_error("impostor amongus");
		
		GameState.system_manned.emit();
	
	
	func is_system_ok(system: System) -> bool:
		return system_hp[system] > 0;
	
	
	func is_system_manned(system: System) -> bool:
		return ships_crew.values().any(func(s) -> bool: return s == system);
	
	
	func _init() -> void:
		system_hp = default_hp.duplicate();
		
		for i in default_crew_count:
			ships_crew[Crewmate.new()] = System.OTHER;


class Crewmate extends RefCounted:
	pass;


class OtherToken extends RefCounted:
	var token_type : Table.TokenType;
	
	
	static func get_nav_token() -> OtherToken:
		var token = new();
		token.token_type = Table.TokenType.SHIP_NAVIGATION;
		return token;
	
	
	static func get_ingot_token() -> OtherToken:
		var token = new();
		token.token_type = Table.TokenType.INGOT;
		return token;
