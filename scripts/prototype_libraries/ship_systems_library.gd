extends RefCounted
class_name ShipSystemLibrary


static var library : Dictionary[String, ShipState.ShipSystem] = {
	"Navigation": ShipState.ShipSystem.new(3, 3)
		.set_name("navigation_system")
		.add_role(ShipState.SystemRole.NAVIGATION),
	"LifeSupport": ShipState.ShipSystem.new(3, 3)
		.set_name("lifesupport_system")
		.add_role(ShipState.SystemRole.LIFE_SUPPORT),
	"Autopilot": ShipState.ShipSystem.new(4, 4)
		.set_name("autopilot_system")
		.add_role(ShipState.SystemRole.AUTOPILOT),
	"Engines": ShipState.ShipSystem.new(3, 3)
		.set_name("engines_system")
		.add_role(ShipState.SystemRole.ENGINES),
	"Hyperdrive": ShipState.ShipSystem.new(3, 3)
		.set_name("hyperdrive_system")
		.add_role(ShipState.SystemRole.HYPERDRIVE),
	"OuterHull": ShipState.ShipSystem.new(8, 1)
		.set_name("outer_hull_system")
		.add_role(ShipState.SystemRole.ARMOR),
	"InnerHull": ShipState.ShipSystem.new(5, 1)
		.set_name("inner_hull_system")
		.add_role(ShipState.SystemRole.ARMOR)
		.add_role(ShipState.SystemRole.SHIELD),
}


static func get_ship_system_by_name(system_name: String) -> ShipState.ShipSystem:
	var system : ShipState.ShipSystem = library.get(system_name, ShipState.ShipSystem.get_dummy());
	return system.clone();


func _init() -> void:
	push_error("don't do that, this is a static class");
