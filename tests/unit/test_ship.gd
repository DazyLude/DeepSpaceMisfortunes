extends GutTest


func test_ship_creation() -> void:
	var ship = ShipState.new();
	assert_no_new_orphans();


func test_empty_ship_behavior() -> void:
	var ship = ShipState.new();
	
	assert_eq(ship.get_free_crewmates().size(), ShipState.default_crew_count);
	assert_eq(ship.get_total_damage(), 0);
	
	assert_true(ship.get_system_by_slot(0).is_dummy);
	assert_true(ship.get_system_by_slot(-1).is_dummy);
	assert_true(ship.get_system_by_slot(1).is_dummy);
	
	for role_key in ShipState.SystemRole:
		assert_false(ship.is_role_ok(ShipState.SystemRole[role_key]));
		assert_false(ship.is_role_manned(ShipState.SystemRole[role_key]));
	
	assert_eq(ship.get_random_non_zero_hp_slot(), ShipState.FREE_CREW_SLOT);
	assert_eq(ship.get_random_working_system_slot(), ShipState.FREE_CREW_SLOT);


func test_crew_manning_and_resetting() -> void:
	var ship = ShipState.new();
	
	ship.reset_crew();
	assert_eq(ship.get_free_crewmates().size(), ShipState.default_crew_count);
	
	ship.man_system(ship.get_free_crewmates()[0], 0);
	assert_eq(ship.get_free_crewmates().size(), ShipState.default_crew_count - 1);
	
	ship.reset_crew();
	assert_eq(ship.get_free_crewmates().size(), ShipState.default_crew_count);


func test_adding_systems() -> void:
	var ship = ShipState.new();
	
	var system_1 = ShipState.ShipSystem.get_dummy();
	system_1.add_role(ShipState.SystemRole.ENGINES);
	system_1.is_dummy = false;
	
	var system_2 = ShipState.ShipSystem.get_dummy();
	system_2.add_role(ShipState.SystemRole.NAVIGATION);
	system_2.is_dummy = false;
	
	var system_3 = ShipState.ShipSystem.get_dummy();
	system_3.add_role(ShipState.SystemRole.LIFE_SUPPORT);
	system_3.is_dummy = false;
	
	var system_4 = ShipState.ShipSystem.get_dummy();
	system_4.add_role(ShipState.SystemRole.HYPERDRIVE);
	system_4.is_dummy = false;
	
	var system_5 = ShipState.ShipSystem.get_dummy();
	system_5.add_role(ShipState.SystemRole.ARMOR);
	system_5.is_dummy = false;
	
	ship.add_system_to_ship_at(system_1, 0);
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.ENGINES), "1 system");
	assert_true(ship.get_system_by_slot(1).is_dummy, "1 systems end");
	
	ship.add_system_to_ship_inside(system_2);
	
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.ENGINES), "2 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(1), ShipState.SystemRole.NAVIGATION), "2 systems");
	assert_true(ship.get_system_by_slot(2).is_dummy, "2 systems end");
	
	ship.add_system_to_ship_outside(system_3);
	
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.LIFE_SUPPORT), "3 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(1), ShipState.SystemRole.ENGINES), "3 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(2), ShipState.SystemRole.NAVIGATION), "3 systems");
	assert_true(ship.get_system_by_slot(3).is_dummy, "3 systems end");
	
	ship.add_system_to_ship_at(system_4, 3);
	
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.LIFE_SUPPORT), "4 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(1), ShipState.SystemRole.ENGINES), "4 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(2), ShipState.SystemRole.NAVIGATION), "4 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(3), ShipState.SystemRole.HYPERDRIVE), "4 systems");
	assert_true(ship.get_system_by_slot(4).is_dummy, "4 systems end");
	
	ship.add_system_to_ship_at(system_5, 2);
	
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.LIFE_SUPPORT), "5 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(1), ShipState.SystemRole.ENGINES), "5 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(2), ShipState.SystemRole.ARMOR), "5 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(3), ShipState.SystemRole.NAVIGATION), "5 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(4), ShipState.SystemRole.HYPERDRIVE), "5 systems");
	assert_true(ship.get_system_by_slot(5).is_dummy, "5 systems end");
	
	ship.remove_system_from_ship_at(3);
	ship.remove_system_from_ship_at(1);
	ship.remove_system_from_ship_at(0);
	
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(0), ShipState.SystemRole.ARMOR), "2 systems");
	assert_true(ship.is_system_of_a_role(ship.get_system_by_slot(1), ShipState.SystemRole.HYPERDRIVE), "2 systems");
	assert_true(ship.get_system_by_slot(2).is_dummy, "2 systems end");
	
	# adding duplicate systems
	ship.add_system_to_ship_at(system_4, 3);
	ship.add_system_to_ship_inside(system_4);
	ship.add_system_to_ship_outside(system_4);
	
	assert_true(ship.get_system_by_slot(2).is_dummy, "still 2 systems");


func test_damaging_and_getting_systems() -> void:
	var ship = ShipState.new();
	
	var system_1 = ShipState.ShipSystem.get_dummy();
	system_1.add_role(ShipState.SystemRole.ENGINES);
	system_1.is_dummy = false;
	
	var system_2 = ShipState.ShipSystem.get_dummy();
	system_2.add_role(ShipState.SystemRole.NAVIGATION);
	system_2.is_dummy = false;
	
	ship.add_system_to_ship_inside(system_1);
	ship.take_physical_damage(0, 1);
	assert_false(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	
	ship.add_system_to_ship_inside(system_2);
	assert_true(ship.is_role_ok(ShipState.SystemRole.NAVIGATION));
	
	for i in range(100):
		assert_eq(ship.get_random_non_zero_hp_slot(), 1);
		assert_eq(ship.get_random_working_system_slot(), 1);


func test_physical_damage() -> void:
	pass;


func test_electrical_damage() -> void:
	pass;


func test_total_damage() -> void:
	pass;


func test_repair_full() -> void:
	pass;


func test_manning_and_normal_repair() -> void:
	pass;
