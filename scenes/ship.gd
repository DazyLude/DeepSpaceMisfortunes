extends Node2D
class_name Ship;


func get_active_zones() -> Array[GenericTableZone]:
	var zones : Array[GenericTableZone] = [$CrewmateAcceptor, $IngotAcceptor];
	return zones;
