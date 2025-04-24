extends RefCounted
class_name ShipState


signal system_damaged(int);
signal system_repaired(int);
signal system_manned(int);


enum SystemRole {
	LIFE_SUPPORT, # ship without lifesupport doesn't support it's living crew 
	NAVIGATION, # ship without navigation can't be controlled
	
	ENGINES, # ship without engines can't travel laterally
	HYPERDRIVE, # ship without hyperdrives can't change depth
	
	ARMOR, # armor adsorbs physical damage
	SHIELD, # shield blocks electric damage
	AUTOPILOT, # autopilot serves as an additional action
	
	EASY_REPAIR,
	AUTO_REPAIR,
};


enum DamageType {
	PHYSICAL,
	ELECTRIC,
};


const default_crew_count : int = 3;
const autorepair_strength : int = 1;


var system_slots : Array[ShipSystem] = [];
var ships_crew : Dictionary[Crewmate, int] = {};

# not referencing GameStates rng directly to decouple classes.
# GameState's rng can be set after initialization.
var rng_ref : RandomNumberGenerator = null :
	get:
		if rng_ref == null:
			rng_ref = RandomNumberGenerator.new();
		return rng_ref;


func get_total_damage() -> int:
	var total : int = 0;
	
	for system in system_slots:
		total += system.max_hp - system.hp;
	
	return total;


## physical damage targets a slot, and the outer systems with "ARMOR" role adsorb the damage they can.
## physical damage pierces the ship until it reaches the targeted system, or is depleted on the way.
func take_physical_damage(slot: int, damage: int) -> void:
	var outer_armor_slots : Array[int] = [];
	for idx in slot:
		var outer_system = get_system_by_slot(idx);
		if is_system_of_a_role(outer_system, SystemRole.ARMOR) and is_system_ok(outer_system):
			outer_armor_slots.push_back(idx);
	
	var remaining_damage = damage;
	
	for armor_idx in outer_armor_slots:
		var armor = get_system_by_slot(armor_idx);
		
		var max_taken_damage = clampi(armor.hp - armor.functional_hp + 1, 0, armor.hp);
		
		if remaining_damage - max_taken_damage > 0:
			armor.hp -= max_taken_damage;
		else:
			armor.hp -= remaining_damage;
		
		remaining_damage -= max_taken_damage;
		system_damaged.emit(armor_idx);
		
		if remaining_damage <= 0:
			remaining_damage = 0;
			return;
	
	var target = get_system_by_slot(slot);
	# the only difference between "armor" and targeted systems,
	# is that max hp is equal to the full hp of the system.
	var max_taken_damage = maxi(target.hp, 0);
	target.hp -= mini(max_taken_damage, remaining_damage);
	
	system_damaged.emit(slot);


## electric damage targets a slot, but is blocked by the outermost system with "SHIELD" role
func take_electric_damage(slot: int, damage: int) -> void:
	var damaged_slot = slot;
	
	for idx in slot:
		var outer_system = get_system_by_slot(idx);
		if is_system_of_a_role(outer_system, SystemRole.SHIELD) and is_system_ok(outer_system):
			damaged_slot = idx;
			break;
	
	var damaged_system = get_system_by_slot(damaged_slot);
	
	var max_taken_damage = maxi(damaged_system.hp, 0);
	damaged_system.hp -= mini(max_taken_damage, damage);
	
	system_damaged.emit(damaged_slot);


func get_random_working_system_slot() -> int:
	var system_idxs := [];
	
	for idx in system_slots.size():
		if is_system_ok(get_system_by_slot(idx)):
			system_idxs.push_back(idx);
	
	if system_idxs.is_empty():
		return get_random_non_zero_hp_slot();
	
	return system_idxs[rng_ref.randi_range(0, system_idxs.size() - 1)];


func get_random_non_zero_hp_slot() -> int:
	var system_idxs := [];
	
	for idx in system_slots.size():
		if get_system_by_slot(idx).hp > 0:
			system_idxs.push_back(idx);
	
	if system_idxs.is_empty():
		return 0;
	
	return system_idxs[rng_ref.randi_range(0, system_idxs.size() - 1)];


func repair_system_in_a_slot(slot: int, repair_by: int, to_full: bool = false) -> void:
	var system_ref = get_system_by_slot(slot);
	
	if to_full:
		system_ref.hp = system_ref.max_hp;
		system_repaired.emit(slot);
	elif repair_by > 0:
		var modded_repair_by := repair_by;
		
		if is_system_of_a_role(system_ref, SystemRole.EASY_REPAIR):
			modded_repair_by *= 2;
		
		system_ref.hp = mini(system_ref.max_hp, system_ref.hp + modded_repair_by)
		system_repaired.emit(slot);


func repair_systems() -> void:
	for system_idx in system_slots.size():
		var system = get_system_by_slot(system_idx);
		if is_system_of_a_role(system, SystemRole.AUTO_REPAIR):
			repair_system_in_a_slot(system_idx, autorepair_strength);
	
	for crewmate in ships_crew:
		var manned_slot = ships_crew[crewmate];
		repair_system_in_a_slot(manned_slot, crewmate.repair_strength);


func full_repair() -> void:
	for slot in system_slots.size():
		repair_system_in_a_slot(slot, 0, true);


func reset_crew() -> void:
	for mate in ships_crew:
		ships_crew[mate] = 0;
	
	system_manned.emit();


func man_system(mate: Crewmate, system_slot: int) -> void:
	if mate in ships_crew:
		ships_crew[mate] = system_slot;
	else:
		push_error("impostor amongus");
	
	system_manned.emit();


func stop_manning(mate: Crewmate) -> void:
	if mate in ships_crew:
		ships_crew[mate] = -1;
	else:
		push_error("impostor amongus");
	
	system_manned.emit();


func is_system_of_a_role(system: ShipSystem, role: SystemRole) -> bool:
	return system.roles.has(role);


func is_system_ok(system: ShipSystem) -> bool:
	return system.hp > 0 and system.hp >= system.functional_hp;


func is_role_ok(role: SystemRole) -> bool:
	var systems_of_a_role := system_slots.filter(is_system_of_a_role.bind(role));
	var ok_systems_of_a_role := systems_of_a_role.filter(is_system_ok);
	
	return ok_systems_of_a_role.size() > 0;


func is_role_manned(role: SystemRole) -> bool:
	var manned_systems := ships_crew.values().map(get_system_by_slot);
	var manned_of_a_role := manned_systems.filter(is_system_of_a_role.bind(role));
	
	return manned_of_a_role.size() > 0;


func is_system_slot_manned(system_slot: int) -> bool:
	return ships_crew.values().has(system_slot);


## adds a system to the ships innermost slot
func add_system_to_ship_inside(system: ShipSystem) -> void:
	system_slots.push_back(system);

## adds a system to the ships outermost slot
func add_system_to_ship_outside(system: ShipSystem) -> void:
	system_slots.push_front(system);

## adds a system to the ships outermost slot
func add_system_to_ship_at(system: ShipSystem, slot: int) -> void:
	system_slots.insert(slot, system);


func get_system_by_slot(slot: int) -> ShipSystem:
	if slot < 0 or slot >= system_slots.size():
		return ShipSystem.get_dummy();
	
	var requested_system_ref = system_slots[slot];
	
	if requested_system_ref == null:
		return ShipSystem.get_dummy();
	
	return requested_system_ref;


func _init() -> void:
	for i in default_crew_count:
		ships_crew[Crewmate.new()] = -1;


class ShipSystem extends RefCounted:
	var hp : int = 0;
	var max_hp : int = 0;
	
	## threshold hp value, minimal hp for a system to work
	## functional hp of zero means that system works always
	var functional_hp : int = 0; 
	
	## roles define functional capabilities of a system
	var roles : Array[SystemRole] = [];
	
	## used by "dummy" systems for debugging purposes
	var is_dummy : bool = false;
	
	
	var name : String = "";
	
	var full_texture : Texture2D = null;
	var damaged_texture : Texture2D = null;
	var broken_texture : Texture2D = null;
	
	## Dummy systems have 1 hp and do nothing. They also have "is_dummy" field checked.
	static func get_dummy() -> ShipSystem:
		var new_system = ShipSystem.new(1, 1);
		new_system.is_dummy = true;
		return new_system;
	
	## Adds a role to the system's roles. Can be chained. 
	func add_role(role: SystemRole) -> ShipSystem:
		if not roles.has(role):
			roles.push_back(role);
		
		return self;
	
	## Set system's name. Used for display purposes. Can be chained with other methods.
	func set_name(new_name: String) -> ShipSystem:
		self.name = new_name;
		return self;
	
	## Set system's sprites. Can be chained with other methods.
	func set_sprites(full: Texture2D, damaged: Texture2D, broken: Texture2D) -> ShipSystem:
		self.full_texture = full;
		self.damaged_texture = damaged;
		self.broken_texture = broken;
		return self;
	
	
	func _init(max: int, functional: int) -> void:
		if max <= 0:
			push_error("system's maximum hp is non positive. Returning the \"default\" system");
			return;
		
		max_hp = max;
		hp = max;
		functional_hp = functional;
		
		if functional_hp > max_hp:
			push_warning("system's maximum hp is less than functional hp. System won't work.");
		
		if functional_hp == 0:
			push_warning("system's functional hp is 0. System will work always.");


class Crewmate extends RefCounted:
	var repair_strength : int = 1;
