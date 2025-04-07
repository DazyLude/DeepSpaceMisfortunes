extends RefCounted
class_name EventPool


## key - event, value - weight 
var events : Array[GenericEvent]
var weights : Array[float] = [];


func add_event_with_weight(event: GenericEvent, weight: float) -> void:
	events.push_back(event);
	weights.push_back(weight);


func reduce_limited_events_weight(event: GenericEvent) -> void:
	var event_idx = events.find(event);
	
	if event_idx == -1:
		return;
	
	match event.is_consumed:
		GenericEvent.LimitedType.LIMITED_PER_LAYER:
			weights[event_idx] -= 1.0;
		GenericEvent.LimitedType.LIMITED_GLOBALLY:
			weights[event_idx] = 0;


func pull_random_event() -> GenericEvent:
	var event_idx = GameState.rng.rand_weighted(weights);
	var event = events[event_idx];
	
	match event.is_consumed:
		GenericEvent.LimitedType.LIMITED_PER_LAYER:
			reduce_limited_events_weight(event);
		GenericEvent.LimitedType.LIMITED_GLOBALLY:
			for pool in GameState.event_pools.values():
				pool.reduce_limited_events_weight(event);
	
	return event;


static func get_placeholder_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.NOTHING: 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_test_pool() -> EventPool:
	var placeholder_weights : Array[GlobalEventPool.EventID] = [
		#GlobalEventPool.EventID.NOTHING : 1.0,
		#GlobalEventPool.EventID.ASTEROID : 1.0,
		GlobalEventPool.EventID.COSMOCOP,
		
		#GlobalEventPool.EventID.POWER_SURGE : 1.0,
		#GlobalEventPool.EventID.PLASMA_INCARNATE : 1.0,
		#GlobalEventPool.EventID.SPACE_RAY : 1.0,
		#GlobalEventPool.EventID.FLUCTUATION_UP : 1.0,
		#GlobalEventPool.EventID.FLUCTUATION_DOWN : 1.0,
		#GlobalEventPool.EventID.ALIENS : 1.0,
		
		#GlobalEventPool.EventID.SHINY : 1.0,
		#GlobalEventPool.EventID.TIME_DILATION : 1.0,
		#
		#GlobalEventPool.EventID.GOODWILL : 1.0,
		#GlobalEventPool.EventID.FRIEND : 1.0,
	];
	
	return get_rigged_pool(placeholder_weights);


static func get_space_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.NOTHING : 8.0,
		GlobalEventPool.EventID.ASTEROID : 2.0,
		GlobalEventPool.EventID.ALIENS : 1.0,
		GlobalEventPool.EventID.COSMOCOP : 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_shallow_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.ASTEROID : 5.0,
		GlobalEventPool.EventID.LARGE_ASTEROID : 1.0,
		GlobalEventPool.EventID.ALIENS : 1.0,
		GlobalEventPool.EventID.SPACE_RAY : 1.0,
		GlobalEventPool.EventID.FLUCTUATION_UP : 1.0,
		GlobalEventPool.EventID.FLUCTUATION_DOWN : 1.0,
		GlobalEventPool.EventID.FRIEND : 1.0,
		GlobalEventPool.EventID.COSMOCOP : 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_normal_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.LARGE_ASTEROID : 5.0,
		GlobalEventPool.EventID.POWER_SURGE : 3.0,
		GlobalEventPool.EventID.SPACE_RAY : 3.0,
		GlobalEventPool.EventID.FLUCTUATION_UP : 3.0,
		GlobalEventPool.EventID.ALIENS : 1.0,
		GlobalEventPool.EventID.ASTEROID : 1.0,
		GlobalEventPool.EventID.SHINY : 1.0,
		GlobalEventPool.EventID.TIME_DILATION : 1.0,
		GlobalEventPool.EventID.FLUCTUATION_DOWN : 2.0,
		GlobalEventPool.EventID.FRIEND : 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_deep_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.PLASMA_INCARNATE : 2.0,
		GlobalEventPool.EventID.POWER_SURGE : 1.0,
		GlobalEventPool.EventID.SPACE_RAY : 1.0,
		GlobalEventPool.EventID.FLUCTUATION_UP : 1.0,
		GlobalEventPool.EventID.SHINY : 1.0,
		GlobalEventPool.EventID.GOODWILL : 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_pool_populated_with_weights(event_weights: Dictionary[GlobalEventPool.EventID, float]) -> EventPool:
	var pool := EventPool.new();
	
	for event_id in event_weights:
		var event := GlobalEventPool.get_event_instance(event_id);
		var weight := event_weights[event_id];
		pool.add_event_with_weight(event, weight);
	
	return pool;


static func get_rigged_pool(weights: Array) -> RiggedPool:
	var pool := RiggedPool.new();
	
	for event_id in weights:
		var event := GlobalEventPool.get_event_instance(event_id);
		var weight = 1.0;
		pool.add_event_with_weight(event, weight);
	
	return pool;


class RiggedPool extends EventPool:
	func pull_random_event() -> GenericEvent:
		if events.size() > 0:
			weights.pop_back();
			return events.pop_back();
		
		else:
			return GlobalEventPool.get_event_instance(GlobalEventPool.EventID.NOTHING);
		
