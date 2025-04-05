extends Node


signal new_phase(round_phase);
signal gameover;
signal victory(score);


enum HyperspaceDepth {
	NONE,
	SHALLOW,
	NORMAL,
	DEEP,
};


enum RoundPhase {
	PREPARATION,
	EXECUTION,
	EVENT,
	SHIP_ACTION,
};


const TRAVEL_GOAL : float = 20.0;
const GAMEOVER_TIME : int = 25;


var rng := RandomNumberGenerator.new();


var ship := ShipState.new();
var travel_distance : float = 0.0;
var hyper_depth : HyperspaceDepth = HyperspaceDepth.NONE;
var current_phase : RoundPhase = RoundPhase.PREPARATION;
var round_n : int = 0;

var score : int = 0;


var event_pools : Dictionary[HyperspaceDepth, EventPool] = {};


func advance_phase() -> void:
	match current_phase:
		#TODO
		_:
			pass;


func _init() -> void:
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
		var system : System = GameState.rng.randi_range(0, System.size() - 2);
		
		match damage_type:
			DamageType.PHYSICAL:
				take_physical_damage(system, value);
			DamageType.ELECTRIC:
				take_electric_damage(system, value);
	
	
	func man_system(mate: Crewmate, system: System) -> void:
		if mate in ships_crew:
			ships_crew[mate] = system;
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
