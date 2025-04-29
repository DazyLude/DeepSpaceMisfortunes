extends GutTest


func test_ship_creation() -> void:
	var ship = ShipState.new();
	assert_no_new_orphans();


func test_empty_ship_behavior() -> void:
	var ship = ShipState.new();
	
	assert_eq(ship.get_free_crewmates().size(), 0);
	assert_eq(ship.get_total_damage(), 0);
	
	assert_true(ship.get_system_by_slot(0).is_dummy);
	assert_true(ship.get_system_by_slot(-1).is_dummy);
	assert_true(ship.get_system_by_slot(1).is_dummy);
	
	var check = false;
	for role_key in ShipState.SystemRole:
		var role = ShipState.SystemRole[role_key];
		
		var role_ok_or_manned = ship.is_role_ok(role) or ship.is_role_manned(role); # false
		var role_has_no_broken_slot = ship.get_broken_system_slot_of_a_role(role) \
			== ShipState.FREE_CREW_SLOT; # true
		
		check = role_ok_or_manned or not role_has_no_broken_slot;
		if check:
			break;
	
	assert_false(check, "system roles not present on an empty ship");
	
	assert_eq(ship.get_random_non_zero_hp_slot(), ShipState.FREE_CREW_SLOT);
	assert_eq(ship.get_random_working_system_slot(), ShipState.FREE_CREW_SLOT);


func test_crew_manning_and_resetting() -> void:
	var ship = ShipState.new();
	const crew_count = 3;
	
	for i in crew_count:
		ship.add_crewmate(ShipState.Crewmate.new());
	
	ship.reset_crew();
	assert_eq(ship.get_free_crewmates().size(), crew_count);
	
	ship.man_system(ship.get_free_crewmates()[0], 0);
	assert_eq(ship.get_free_crewmates().size(), crew_count - 1);
	
	ship.reset_crew();
	assert_eq(ship.get_free_crewmates().size(), crew_count);


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
	assert_eq(ship.get_broken_system_slot_of_a_role(ShipState.SystemRole.ENGINES), 0);
	
	ship.add_system_to_ship_inside(system_2);
	assert_true(ship.is_role_ok(ShipState.SystemRole.NAVIGATION));
	
	var check = true;
	for i in range(10):
		check = ship.get_random_non_zero_hp_slot() == 1 and ship.get_random_working_system_slot() == 1;
		
		if not check:
			break;
	
	assert_true(check, "getting healthy random system")


func test_physical_damage() -> void:
	var ship = ShipState.new();
	
	var system_1 = ShipState.ShipSystem.new(5, 3);
	system_1.add_role(ShipState.SystemRole.ARMOR);
	ship.add_system_to_ship_inside(system_1);
	
	var system_2 = ShipState.ShipSystem.new(1, 1);
	system_2.add_role(ShipState.SystemRole.ENGINES);
	ship.add_system_to_ship_inside(system_2);
	
	var system_3 = ShipState.ShipSystem.new(5, 1);
	system_3.add_role(ShipState.SystemRole.ARMOR);
	ship.add_system_to_ship_inside(system_3);
	
	var system_4 = ShipState.ShipSystem.new(1, 1);
	system_4.add_role(ShipState.SystemRole.LIFE_SUPPORT);
	ship.add_system_to_ship_inside(system_4);
	
	ship.take_physical_damage(3, 1);
	assert_eq(ship.get_total_damage(), 1);
	assert_true(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	assert_true(ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT));
	
	ship.take_physical_damage(3, 10);
	assert_eq(ship.get_total_damage(), 9); # 3 + 5 + 1
	assert_true(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	assert_false(ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT));


func test_electrical_damage() -> void:
	var ship = ShipState.new();
	
	var system_1 = ShipState.ShipSystem.new(5, 1);
	system_1.add_role(ShipState.SystemRole.SHIELD);
	ship.add_system_to_ship_inside(system_1);
	
	var system_2 = ShipState.ShipSystem.new(1, 1);
	system_2.add_role(ShipState.SystemRole.ENGINES);
	ship.add_system_to_ship_inside(system_2);
	
	var system_3 = ShipState.ShipSystem.new(1, 1);
	system_3.add_role(ShipState.SystemRole.LIFE_SUPPORT);
	ship.add_system_to_ship_inside(system_3);
	
	ship.take_electric_damage(2, 1);
	assert_eq(ship.get_total_damage(), 1);
	assert_true(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	assert_true(ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT));
	
	ship.take_electric_damage(2, 10);
	assert_eq(ship.get_total_damage(), 5); # 5
	assert_true(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	assert_true(ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT));
	
	ship.take_electric_damage(2, 10);
	assert_eq(ship.get_total_damage(), 6); # 5 + 1
	assert_true(ship.is_role_ok(ShipState.SystemRole.ENGINES));
	assert_false(ship.is_role_ok(ShipState.SystemRole.LIFE_SUPPORT));


func test_repair_full() -> void:
	var ship = ShipState.new();
	
	var system_1 = ShipState.ShipSystem.new(5, 1);
	system_1.add_role(ShipState.SystemRole.SHIELD);
	ship.add_system_to_ship_inside(system_1);
	
	var system_2 = ShipState.ShipSystem.new(5, 1);
	system_2.add_role(ShipState.SystemRole.ARMOR);
	ship.add_system_to_ship_inside(system_2);
	
	var system_3 = ShipState.ShipSystem.new(1, 1);
	system_3.add_role(ShipState.SystemRole.ENGINES);
	ship.add_system_to_ship_inside(system_3);
	
	ship.take_electric_damage(2, 10);
	ship.take_physical_damage(2, 10);
	assert_eq(ship.get_total_damage(), 11);
	
	ship.full_repair();
	assert_eq(ship.get_total_damage(), 0);


func test_manning_and_normal_repair() -> void:
	var ship = ShipState.new();
	const crew_count = 3;
	
	for i in crew_count:
		ship.add_crewmate(ShipState.Crewmate.new());
	
	var system_1 = ShipState.ShipSystem.new(5, 1);
	system_1.add_role(ShipState.SystemRole.SHIELD);
	system_1.add_role(ShipState.SystemRole.AUTO_REPAIR);
	ship.add_system_to_ship_inside(system_1);
	
	var system_2 = ShipState.ShipSystem.new(5, 1);
	system_2.add_role(ShipState.SystemRole.ARMOR);
	system_1.add_role(ShipState.SystemRole.EASY_REPAIR);
	ship.add_system_to_ship_inside(system_2);
	
	var system_3 = ShipState.ShipSystem.new(1, 1);
	system_3.add_role(ShipState.SystemRole.ENGINES);
	ship.add_system_to_ship_inside(system_3);
	
	ship.take_electric_damage(2, 10);
	ship.take_physical_damage(2, 10);
	
	var slackers = ship.get_free_crewmates();
	assert_true(slackers.size() >= 2);
	var crewmate_1 = slackers[0];
	var crewmate_2 = slackers[1];
	
	ship.man_system(crewmate_1, 1)
	ship.man_system(crewmate_2, 2)
	
	assert_eq(ship.get_free_crewmates().size(), slackers.size() - 2);
	ship.repair_systems();
	
	assert_eq(ship.get_total_damage(), 7); # 11 - 1 - 1 - 2
