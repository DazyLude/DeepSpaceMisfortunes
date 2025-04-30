extends RefCounted
class_name Utils


static func _property_dict_to_name(property_dict: Dictionary) -> String:
	return property_dict["name"];

## Compares two objects.[br]
## Returns "ok" result with true value if objects have equal properties.[br]
## Returns "err" result with the reason for comparison failure otherwise.
static func expect_objects_properties_equal(object_a: Object, object_b: Object) -> Result:
	var properties_a : Array = object_a.get_property_list().map(_property_dict_to_name);
	var properties_b : Array = object_b.get_property_list().map(_property_dict_to_name);
	
	# check property count 
	if properties_a.size() != properties_b.size():
		return Result.wrap_err("different property counts");
	
	# check property names
	for property in properties_a:
		if properties_b.has(property):
			continue;
		else:
			return Result.wrap_err("different property names");
	
	# check property values
	# objects and collections (arrays and dictionaries) are not checked
	for property in properties_a:
		var value1 = object_a.get(property);
		var value2 = object_b.get(property);
		
		match typeof(value1):
			TYPE_DICTIONARY, TYPE_OBJECT, TYPE_ARRAY when typeof(value1) == typeof(value2):
				continue;
			_ when typeof(value1) != typeof(value2):
				return Result.wrap_err(
					"different property types for %s: %s vs %s" % [property, typeof(value1), typeof(value2)]
				);
			_ when value1 == value2:
				continue;
			_:
				return Result.wrap_err(
					"different property values for %s: %s vs %s" % [property, value1, value2]
				);
		
	
	return Result.wrap_ok(true);

## Checks whether a point is between (inclusive) coords_range.x and coords_range.y
static func is_point_within_range(point: float, coords_range: Vector2) -> bool:
	if coords_range.y > coords_range.x:
		return point >= coords_range.x and point <= coords_range.y;
	else:
		return point >= coords_range.y and point <= coords_range.x;
