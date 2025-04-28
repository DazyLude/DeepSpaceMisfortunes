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



class ObjectA extends RefCounted:
	var property : Variant = "value";


class ObjectB extends RefCounted:
	var different_property : Variant = "value";


class ObjectC extends RefCounted:
	var property : Variant;
	var different_property : Variant = "value";
