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


func _add_crewmate_to_system(card: GenericCard, zone: GenericTableZone) -> void:
	GameState.ship.man_system(
		GameState.active_table.active_cards[card], zone_to_system[zone]
	);


func _remove_crewmate_from_system(card: GenericCard) -> void:
	GameState.ship.stop_manning(GameState.active_table.active_cards[card]);


func _ready() -> void:
	for zone in get_active_zones():
		zone.card_recieved.connect(_add_crewmate_to_system.bind(zone));
		zone.card_lost.connect(_remove_crewmate_from_system);
