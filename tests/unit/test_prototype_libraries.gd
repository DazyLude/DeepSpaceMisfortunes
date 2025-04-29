extends GutTest


func library_routine(keys : Array, getter : Callable) -> void:
	var diff_object_check : bool = true;
	var same_values_check : bool = true;
	var comparison_error : String = "";
	
	for key in keys:
		var prototype_a = getter.call(key);
		var prototype_b = getter.call(key);
		
		diff_object_check = not (prototype_a == prototype_b);
		
		var comparison := Utils.expect_objects_properties_equal(prototype_a, prototype_b);
		if not comparison.is_ok():
			same_values_check = false;
			comparison_error = comparison.get_error();
		
		if not (diff_object_check and same_values_check):
			break;
	
	assert_true(diff_object_check, "library returns different objects");
	assert_true(same_values_check, "which have same property values: " + comparison_error);


func test_ship_systems_library() -> void:
	library_routine(ShipSystemLibrary.library.keys(), ShipSystemLibrary.get_ship_system_by_name);


func test_ship_library() -> void:
	library_routine(ShipLibrary.library.keys(), ShipLibrary.get_ship_by_name);


func test_pool_library() -> void:
	library_routine(PoolLibrary.library.keys(), PoolLibrary.get_event_pool_by_name);
