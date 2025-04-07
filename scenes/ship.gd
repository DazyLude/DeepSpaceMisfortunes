extends Node2D
class_name Ship;


@onready
var zone_to_system : Dictionary[GenericTableZone, GameState.ShipState.System] = {
	$LifeSupportSlot: GameState.ShipState.System.LIFE_SUPPORT,
	$NavigationSlot: GameState.ShipState.System.NAVIGATION,
	$AutopilotSlot: GameState.ShipState.System.AUTOPILOT,
	$InnerHullSlot: GameState.ShipState.System.INNER_HULL,
	$OuterHullSlot: GameState.ShipState.System.OUTER_HULL,
	$EnginesSlot: GameState.ShipState.System.ENGINES,
	$HyperSlot: GameState.ShipState.System.HYPER_ENGINES
};


func get_active_zones() -> Array[GenericTableZone]:
	var zones : Array[GenericTableZone] = [];
	for c in self.get_children().filter(func(x): return x is EventZone):
		zones.push_back(c);

	return zones;


func update_manned_icons() -> void:
	pass;


func on_system_damaged(system: GameState.ShipState.System) -> void:
	pass;


func on_system_repaired(system: GameState.ShipState.System) -> void:
	pass;


func update_warning_icon(_p) -> void:
	$Warning.visible = GameState.life_support_failure;


func _add_crewmate_to_system(card: GenericCard, zone: GenericTableZone) -> void:
	GameState.ship.man_system(
		GameState.active_table.active_cards[card], zone_to_system[zone]
	);


func _remove_crewmate_from_system(card: GenericCard) -> void:
	GameState.ship.stop_manning(GameState.active_table.active_cards[card]);


func _ready() -> void:
	GameState.new_phase.connect(update_warning_icon);
	$Warning.hide();
	
	GameState.system_damaged.connect(on_system_damaged);
	GameState.system_repaired.connect(on_system_repaired);
	GameState.system_manned.connect(update_manned_icons);
	
	for zone in get_active_zones():
		zone.card_recieved.connect(_add_crewmate_to_system.bind(zone));
		zone.card_lost.connect(_remove_crewmate_from_system);
