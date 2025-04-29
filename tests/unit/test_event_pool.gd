extends GutTest


func ne_null(value: Variant) -> bool:
	return value != null;


func load_all_events() -> Dictionary[EventLoader.EventID, Node2D]:
	var event_instances : Dictionary[EventLoader.EventID, Node2D];
	
	var tested_events := EventLoader.EventID.values();
	
	for event_id in tested_events:
		event_instances[event_id] = EventLoader.get_event_instance(event_id);
	
	return event_instances;


func test_load_all() -> void:
	var all_static_events := load_all_events();
	
	assert_true(all_static_events.values().all(ne_null));
	
	for event in all_static_events.values():
		if event != null:
			event.free();
	
	# this test sometimes affects orphan count without this await
	
	# the GUT-counted orphan nodes are not shown with:
	#print(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT));
	#print_orphan_nodes();
	
	# probably connected to https://github.com/bitwes/Gut/issues/690
	
	assert_no_new_orphans();
	await wait_frames(16);


# the following test is made for code coverage by the compiler
# it also produces an ungodly amount of orphans
#func test_run_all_events() -> void:
	#GameState.new_game();
	#var all_static_events := load_all_events();
	#
	#var iterators : Array = [];
	#
	#for event_id in all_static_events:
		#var event = all_static_events[event_id];
		#var test_inputs_iterator : Array[Dictionary];
		#
		#if event != null:
			#test_inputs_iterator = event.get_inputs_test_iterator();
			#event.free();
		#else:
			#test_inputs_iterator = [];
		#
		#iterators.push_back([event_id, test_inputs_iterator]);
	#
	#
	#for iterator in iterators:
		#for iterable in iterator[1]:
			#var fresh_event = EventLoader.get_event_instance(iterator[0]);
			## prepare
			#fresh_event._prepare();
			#
			#for i in iterable["prep_times"]:
				#fresh_event.event_callables[iterable["before_idx"]].call();
			#
			## reset
			#for i in iterable["prep_times"]:
				#fresh_event.event_callables[iterable["after_idx"]].call();
			#
			## run
			#if fresh_event._can_play():
				#fresh_event._action();
			#
			#fresh_event.free();
			#assert_no_new_orphans();


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
	pool.pull_random_event(RandomNumberGenerator.new()).free();
	
	assert_eq(pool.get_event_weight(test_for_event), 1.0);
	
	pool.pull_random_event(RandomNumberGenerator.new()).free();
	
	assert_eq(pool.get_event_weight(test_for_event), 0.0);


func test_event_pool_nonnegative_weight() -> void:
	var test_for_event := EventLoader.EventID.GENERIC_LIMITED;
	var pool := EventPool.new();
	
	pool.add_event_with_weight(test_for_event, -0.5);
	assert_eq(pool.get_event_weight(test_for_event), 0.0);
	
	pool.add_event_with_weight(test_for_event, 0.5);
	pool.pull_random_event(RandomNumberGenerator.new()).free();
	
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
		var event = pool.pull_random_event(RandomNumberGenerator.new());
		
		pulled_zero_weight = not (event.get_script() == event_loader_event.get_script());
		if pulled_zero_weight: break;
		
		event.free();
	
	event_loader_event.free();
	assert_false(pulled_zero_weight);
	
	await wait_frames(16);
