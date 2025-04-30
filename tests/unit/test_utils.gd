extends GutTest


func test_object_property_comparison() -> void:
	var obja = ObjectA.new();
	var objb = ObjectB.new();
	var objc = ObjectC.new();
	var objd = ObjectA.new();
	objd.property = "not value";
	var obje = ObjectA.new();
	
	
	var a_to_b := Utils.expect_objects_properties_equal(obja, objb); # Err "names"
	var a_to_c := Utils.expect_objects_properties_equal(obja, objc); # Err "count"
	var a_to_d := Utils.expect_objects_properties_equal(obja, objd); # Err "values"
	var a_to_e := Utils.expect_objects_properties_equal(obja, obje); # Ok
	
	assert_false(a_to_b.is_ok(), a_to_b.get_error());
	assert_false(a_to_c.is_ok(), a_to_c.get_error());
	assert_false(a_to_d.is_ok(), a_to_d.get_error());
	assert_true(a_to_e.is_ok());


func test_point_range_comparison() -> void:
	var point1 : float = 1.0;
	var point2 : float = -10.0;
	var point_inf : float = INF;
	var point_nan : float = NAN;
	
	var zero_range := Vector2(0.0, 0.0);
	var normal_range := Vector2(0.0, 1.0);
	var inf_range := Vector2(-INF, INF);
	var nan_range := Vector2(NAN, NAN);
	
	
	assert_false(Utils.is_point_within_range(point1, zero_range));
	assert_false(Utils.is_point_within_range(point2, zero_range));
	assert_false(Utils.is_point_within_range(point_inf, zero_range));
	assert_false(Utils.is_point_within_range(point_nan, zero_range));
	
	assert_true(Utils.is_point_within_range(point1, normal_range));
	assert_false(Utils.is_point_within_range(point2, normal_range));
	assert_false(Utils.is_point_within_range(point_inf, normal_range));
	assert_false(Utils.is_point_within_range(point_nan, normal_range));
	
	assert_true(Utils.is_point_within_range(point1, inf_range));
	assert_true(Utils.is_point_within_range(point2, inf_range));
	assert_true(Utils.is_point_within_range(point_inf, inf_range));
	assert_false(Utils.is_point_within_range(point_nan, inf_range));
	
	assert_false(Utils.is_point_within_range(point1, nan_range));
	assert_false(Utils.is_point_within_range(point2, nan_range));
	assert_false(Utils.is_point_within_range(point_inf, nan_range));
	assert_false(Utils.is_point_within_range(point_nan, nan_range));


class ObjectA extends RefCounted:
	var property : Variant = "value";


class ObjectB extends RefCounted:
	var different_property : Variant = "value";


class ObjectC extends RefCounted:
	var property : Variant;
	var different_property : Variant = "value";
