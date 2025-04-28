extends GutTest


func library_routine(keys : Array, getter : Callable) -> void:
	for key in keys:
		var system_a = getter.call(key);
		var system_b = getter.call(key);
		
		assert_false(system_a == system_b, "library returns different objects");
		var comparison := Utils.expect_objects_properties_equal(system_a, system_b);
		
		if comparison.is_ok():
			assert_true(comparison.unwrap(), "which have same property values");
		else:
			assert_true(false, comparison.get_error());


func test_ship_systems_library() -> void:
	library_routine(ShipSystemLibrary.library.keys(), ShipSystemLibrary.get_ship_system_by_name);


func test_ship_library() -> void:
	library_routine(ShipLibrary.library.keys(), ShipLibrary.get_ship_by_name);
