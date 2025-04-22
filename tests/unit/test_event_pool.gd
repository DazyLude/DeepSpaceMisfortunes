extends GutTest


func ne_null(value: Variant) -> bool:
	return value != null;


func test_event_loader_load_all() -> void:
	var all_static_events := EventLoader.load_all();
	
	assert_true(all_static_events.values().all(ne_null));
	
	for event in all_static_events.values():
		event.free();
	
	# this test sometimes affects orphan count without this await
	
	# the GUT-counted orphan nodes are not shown with:
	#print(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT));
	#print_orphan_nodes();
	
	# probably connected to https://github.com/bitwes/Gut/issues/690
	await wait_frames(16);


func test_event_pool_add_event() -> void:
	var test_event := EventLoader.EventID.GENERIC;
	var pool := EventPool.new();
	
	pool.add_event_with_weight(test_event, 1.0);
	assert_eq(pool.get_event_weight(test_event), 1.0);


func test_event_pool_set_weight() -> void:
	var test_event := EventLoader.EventID.GENERIC;
	var pool := EventPool.new();
	
	pool.add_event_with_weight(test_event, 1.0);
	pool.set_event_weight(test_event, 2.0);
	
	assert_eq(pool.get_event_weight(test_event), 2.0);


func test_event_pool_ghost_event_manipulation() -> void:
	var real_event := EventLoader.EventID.GENERIC;
	var fake_event := EventLoader.EventID.GENERIC_LIMITED;
	var pool := EventPool.new();
	
	pool.add_event_with_weight(real_event, 1.0);
	
	assert_ne(real_event, fake_event);
	assert_eq(pool.get_event_weight(fake_event), 0.0);
	
	pool.set_event_weight(fake_event, 1.0);
	
	assert_eq(pool.get_event_weight(fake_event), 0.0);


func test_event_pool_get_event() -> void:
	var test_for_event := EventLoader.EventID.GENERIC;
	
	var pool := EventPool.new();
	pool.add_event_with_weight(test_for_event, 1.0);
	var event := pool.pull_random_event();
	
	var event_loader_event := EventLoader.get_event_instance(test_for_event);
	
	assert_same(event.get_script(), event_loader_event.get_script());
	
	event.free();
	event_loader_event.free();


func test_event_pool_weight_reduced() -> void:
	var test_for_event := EventLoader.EventID.GENERIC_LIMITED;
	
	var pool := EventPool.new();
	pool.add_event_with_weight(test_for_event, 2.0);
	pool.pull_random_event().free();
	
	assert_eq(pool.get_event_weight(test_for_event), 1.0);
	
	pool.pull_random_event().free();
	
	assert_eq(pool.get_event_weight(test_for_event), 0.0);


func test_event_pool_nonnegative_weight() -> void:
	var test_for_event := EventLoader.EventID.GENERIC_LIMITED;
	var pool := EventPool.new();
	
	pool.add_event_with_weight(test_for_event, -0.5);
	assert_eq(pool.get_event_weight(test_for_event), 0.0);
	
	pool.add_event_with_weight(test_for_event, 0.5);
	pool.pull_random_event().free();
	
	assert_eq(pool.get_event_weight(test_for_event), 0.0);
	
	pool.set_event_weight(test_for_event, -1.0);
	
	assert_eq(pool.get_event_weight(test_for_event), 0.0);
	
	pool.set_event_weight(test_for_event, 1.0)
	pool.add_event_with_weight(test_for_event, -1.5);
	
	assert_eq(pool.get_event_weight(test_for_event), 0.0);


func test_event_zero_weight_pull() -> void:
	var zero_weight := EventLoader.EventID.GENERIC_LIMITED;
	var non_zero_weight := EventLoader.EventID.GENERIC;
	
	assert_ne(zero_weight, non_zero_weight);
	
	var pool := EventPool.new();
	pool.add_event_with_weight(zero_weight, 0.0);
	pool.add_event_with_weight(non_zero_weight, 1.0);
	
	var event_loader_event := EventLoader.get_event_instance(non_zero_weight);
	
	var pulled_zero_weight : bool = false;
	for i in 256: # with this amount of pulls, if doesn't fail it won't matter for the player.
		var event = pool.pull_random_event();
		
		pulled_zero_weight = not (event.get_script() == event_loader_event.get_script());
		if pulled_zero_weight: break;
		
		event.free();
	
	event_loader_event.free();
	assert_false(pulled_zero_weight);
	
	await wait_frames(16);
