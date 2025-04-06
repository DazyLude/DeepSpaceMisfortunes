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
	
	match event.LimitedType:
		GenericEvent.LimitedType.LIMITED_PER_LAYER:
			weights[event_idx] -= 1.0;
		GenericEvent.LimitedType.LIMITED_GLOBALLY:
			weights[event_idx] = 0;


func pull_random_event() -> GenericEvent:
	var event_idx = GameState.rng.rand_weighted(weights);
	var event = events[event_idx];
	
	match event.LimitedType:
		GenericEvent.LimitedType.LIMITED_PER_LAYER:
			reduce_limited_events_weight(event);
		GenericEvent.LimitedType.LIMITED_GLOBALLY:
			for pool in GameState.event_pools.values():
				pool.reduce_limited_events_weight(event);
	
	return event;


static func get_placeholder_pool() -> EventPool:
	var placeholder_weights : Dictionary[GlobalEventPool.EventID, float] = {
		GlobalEventPool.EventID.NOTHING: 1.0,
		GlobalEventPool.EventID.ASTEROID: 1.0,
	};
	
	return get_pool_populated_with_weights(placeholder_weights);


static func get_pool_populated_with_weights(event_weights: Dictionary[GlobalEventPool.EventID, float]) -> EventPool:
	var pool := EventPool.new();
	
	for event_id in event_weights:
		var event := GlobalEventPool.get_event_instance(event_id);
		var weight := event_weights[event_id];
		pool.add_event_with_weight(event, weight);
	
	return pool;
