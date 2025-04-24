extends GutTest


func test_ship_creation() -> void:
	var ship = ShipState.new();
	
	assert_no_new_orphans();
