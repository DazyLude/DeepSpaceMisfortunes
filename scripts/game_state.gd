extends Node


signal new_phase(round_phase);

signal new_event(GenericEvent);

signal clear_tokens;
signal new_token(TokenType, RefCounted);

signal gameover(int);
signal victory(int);


enum HyperspaceDepth {
	NONE,
	SHALLOW,
	NORMAL,
	DEEP,
};


enum RoundPhase {
	GAME_START,
	PREPARATION,
	EXECUTION,
	EVENT,
	SHIP_ACTION,
};


const TRAVEL_GOAL : float = 20.0;
const GAMEOVER_TIME : int = 25;


var rng := RandomNumberGenerator.new();


var ship : ShipState;
var travel_distance : float;
var hyper_depth : HyperspaceDepth;
var current_phase : RoundPhase;
var round_n : int = 0;
var score : int = 0;

var active_table : Table = null;


var event_pools : Dictionary[HyperspaceDepth, EventPool] = {};


func advance_phase() -> void:
	match current_phase:
		#TODO
		_ when false:
			new_event.emit();
			new_token.emit();
			gameover.emit(score);
			victory.emit(score);
		
		RoundPhase.SHIP_ACTION, RoundPhase.GAME_START:
			current_phase = RoundPhase.PREPARATION;
			
			for crewmate in ship.ships_crew:
				new_token.emit(Table.TokenType.CREWMATE, crewmate);
			
			new_token.emit(Table.TokenType.SHIP_NAVIGATION, null);
			
			new_event.emit(GlobalEventPool.get_event_instance(GlobalEventPool.EventID.SHIP_NAVIGATION));
		
		RoundPhase.PREPARATION when active_table.current_event._can_play():
			current_phase = RoundPhase.EXECUTION;
			clear_tokens.emit();
			new_event.emit(null);
		
		RoundPhase.EXECUTION:
			current_phase = RoundPhase.EVENT;
			ship.repair_systems();
			new_event.emit(event_pools[hyper_depth].pull_random_event());
		
		RoundPhase.EVENT when active_table.current_event._can_play():
			current_phase = RoundPhase.SHIP_ACTION;
			new_event.emit(null);
		
		RoundPhase.PREPARATION: # has not resolved nav 
			pass;
	
	new_phase.emit(current_phase);


func new_game(table: Table) -> void:
	active_table = table;
	ship = ShipState.new();
	travel_distance = 0.0;
	hyper_depth = HyperspaceDepth.NONE;
	current_phase = RoundPhase.GAME_START;
	round_n = 0;
	score = 0;
	
	for depth in HyperspaceDepth.values():
		event_pools[depth] = EventPool.get_placeholder_pool();


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
	
	
	func take_physical_damage(system: System, damage: int) -> void:
		match system:
			_ when is_system_ok(System.OUTER_HULL):
				system_hp[System.OUTER_HULL] -= damage;
			System.LIFE_SUPPORT, System.NAVIGATION when is_system_ok(System.INNER_HULL):
				system_hp[System.INNER_HULL] -= damage;
			_:
				system_hp[system] -= damage;
	
	
	func take_electric_damage(system: System, damage: int) -> void:
		match system:
			System.LIFE_SUPPORT, System.NAVIGATION when is_system_ok(System.INNER_HULL):
				system_hp[System.INNER_HULL] -= damage;
			_:
				system_hp[system] -= damage;
	
	
	func take_damage_to_random_system(damage_type: DamageType, value: int) -> void:
		var system : System = GameState.rng.randi_range(0, System.size() - 2) as System;
		
		match damage_type:
			DamageType.PHYSICAL:
				take_physical_damage(system, value);
			DamageType.ELECTRIC:
				take_electric_damage(system, value);
	
	
	func repair_system(system: System) -> void:
		if not system_hp.has(system):
			return;
		
		if system_hp[system] < 0:
			system_hp[system] += 1;
		
		system_hp[system] += 1;
		system_hp[system] = mini(system_hp[system], default_hp[system]);
	
	
	func repair_systems() -> void:
		for crewmate in ships_crew.values():
			repair_system(ships_crew[crewmate]);
	
	
	func man_system(mate: Crewmate, system: System) -> void:
		if mate in ships_crew:
			ships_crew[mate] = system;
		else:
			push_error("impostor amongus");
	
	
	func stop_manning(mate: Crewmate) -> void:
		if mate in ships_crew:
			ships_crew[mate] = System.OTHER;
		else:
			push_error("impostor amongus");
	
	
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
