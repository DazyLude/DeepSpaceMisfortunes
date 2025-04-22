extends RefCounted
class_name EventPool


var events : Array[EventLoader.EventID];
var weights : Array[float];


func add_event_with_weight(event_id: EventLoader.EventID, weight: float) -> void:
	if events.has(event_id):
		var idx = events.find(event_id);
		weights[idx] = max(0.0, weights[idx] + weight);
		return;
	
	events.push_back(event_id);
	weights.push_back(max(0.0, weight));



func get_event_weight(event_id: EventLoader.EventID) -> float:
	var event_idx = events.find(event_id);
	
	if event_idx == -1:
		return 0.0;
	
	return weights[event_idx];


func set_event_weight(event_id: EventLoader.EventID, new_weight: float) -> void:
	var event_idx = events.find(event_id);
	
	if event_idx != -1:
		weights[event_idx] = max(new_weight, 0.0);


func reduce_limited_events_weight(event_id: EventLoader.EventID) -> void:
	var weight = self.get_event_weight(event_id);
	
	if weight >= 0.0:
		self.set_event_weight(event_id, max(0.0, weight - 1.0));


func pull_random_event() -> GenericEvent:
	var event_idx := GameState.rng.rand_weighted(weights);
	var event_id := events[event_idx];
	
	var event = EventLoader.get_event_instance(event_id);
	
	match event.is_consumed:
		GenericEvent.LimitedType.LIMITED:
			self.reduce_limited_events_weight(event_id);
	
	return event;


static func get_placeholder_pool() -> EventPool:
	var placeholder_weights : Dictionary[EventLoader.EventID, float] = {
		EventLoader.EventID.NOTHING: 1.0,
	};
	
	return get_pool_from_weights(placeholder_weights);


static func get_test_pool() -> EventPool:
	var placeholder_weights : Array[EventLoader.EventID] = [
		EventLoader.EventID.COSMOCOP,
	];
	
	return get_rigged_pool(placeholder_weights);


static func get_space_pool() -> EventPool:
	var placeholder_weights : Dictionary[EventLoader.EventID, float] = {
		EventLoader.EventID.NOTHING : 8.0,
		EventLoader.EventID.ASTEROID : 2.0,
		EventLoader.EventID.ALIENS : 1.0,
		EventLoader.EventID.COSMOCOP : 1.0,
	};
	
	return get_pool_from_weights(placeholder_weights);


static func get_shallow_pool() -> EventPool:
	var placeholder_weights : Dictionary[EventLoader.EventID, float] = {
		EventLoader.EventID.ASTEROID : 5.0,
		EventLoader.EventID.LARGE_ASTEROID : 1.0,
		EventLoader.EventID.ALIENS : 1.0,
		EventLoader.EventID.SPACE_RAY : 1.0,
		EventLoader.EventID.FLUCTUATION_UP : 1.0,
		EventLoader.EventID.FLUCTUATION_DOWN : 1.0,
		EventLoader.EventID.FRIEND : 1.0,
		EventLoader.EventID.COSMOCOP : 1.0,
	};
	
	return get_pool_from_weights(placeholder_weights);


static func get_normal_pool() -> EventPool:
	var placeholder_weights : Dictionary[EventLoader.EventID, float] = {
		EventLoader.EventID.LARGE_ASTEROID : 5.0,
		EventLoader.EventID.POWER_SURGE : 3.0,
		EventLoader.EventID.SPACE_RAY : 3.0,
		EventLoader.EventID.FLUCTUATION_UP : 3.0,
		EventLoader.EventID.ALIENS : 1.0,
		EventLoader.EventID.ASTEROID : 1.0,
		EventLoader.EventID.SHINY : 1.0,
		EventLoader.EventID.TIME_DILATION : 1.0,
		EventLoader.EventID.FLUCTUATION_DOWN : 2.0,
		EventLoader.EventID.FRIEND : 1.0,
	};
	
	return get_pool_from_weights(placeholder_weights);


static func get_deep_pool() -> EventPool:
	var placeholder_weights : Dictionary[EventLoader.EventID, float] = {
		EventLoader.EventID.PLASMA_INCARNATE : 2.0,
		EventLoader.EventID.POWER_SURGE : 1.0,
		EventLoader.EventID.SPACE_RAY : 1.0,
		EventLoader.EventID.FLUCTUATION_UP : 1.0,
		EventLoader.EventID.SHINY : 1.0,
		EventLoader.EventID.GOODWILL : 1.0,
	};
	
	return get_pool_from_weights(placeholder_weights);


static func get_pool_from_weights(event_weights: Dictionary[EventLoader.EventID, float]) -> EventPool:
	var pool := EventPool.new();
	
	for event_id in event_weights:
		var weight := event_weights[event_id];
		pool.add_event_with_weight(event_id, weight);
	
	return pool;


static func get_rigged_pool(weights: Array) -> RiggedPool:
	var pool := RiggedPool.new();
	
	for event_id in weights:
		var weight = 1.0;
		pool.add_event_with_weight(event_id, weight);
	
	return pool;


class RiggedPool extends EventPool:
	func pull_random_event() -> GenericEvent:
		if events.size() > 0:
			weights.pop_back();
			return events.pop_back();
		
		else:
			return EventLoader.get_event_instance(EventLoader.EventID.GENERIC);
