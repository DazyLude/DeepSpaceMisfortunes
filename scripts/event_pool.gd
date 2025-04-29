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


static func get_pool_from_weights(event_weights: Dictionary[EventLoader.EventID, float]) -> EventPool:
	var pool := EventPool.new();
	
	for event_id in event_weights:
		var weight := event_weights[event_id];
		pool.add_event_with_weight(event_id, weight);
	
	return pool;
