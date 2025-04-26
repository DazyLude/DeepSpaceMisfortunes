extends RefCounted
class_name ShipLibrary


static var library : Dictionary[String, ShipState] = {
	"Standard": ShipState.new()
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("OuterHull"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Hyperdrive"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Engines"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Autopilot"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("InnerHull"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("LifeSupport"))
		.add_system_to_ship_inside(ShipSystemLibrary.get_ship_system_by_name("Navigation")),
}


static func get_ship_by_name(system_name: String) -> ShipState:
	var ship : ShipState = library.get(system_name, ShipState.ShipSystem.get_dummy());
	return ship;


func _init() -> void:
	push_error("don't do that, this is a static class");
