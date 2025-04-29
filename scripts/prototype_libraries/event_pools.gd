extends RefCounted
class_name PoolLibrary


static var library : Dictionary[String, Dictionary] = {
	"Space": {
		EventLoader.EventID.NOTHING : 8.0,
		EventLoader.EventID.ASTEROID : 2.0,
		EventLoader.EventID.ALIENS : 1.0,
		EventLoader.EventID.COSMOCOP : 1.0,
	},
	"Shallow": {
		EventLoader.EventID.ASTEROID : 5.0,
		EventLoader.EventID.LARGE_ASTEROID : 1.0,
		EventLoader.EventID.ALIENS : 1.0,
		EventLoader.EventID.SPACE_RAY : 1.0,
		EventLoader.EventID.FLUCTUATION_UP : 1.0,
		EventLoader.EventID.FLUCTUATION_DOWN : 1.0,
		EventLoader.EventID.FRIEND : 1.0,
		EventLoader.EventID.COSMOCOP : 1.0,
	},
	"Normal": {
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
	},
	"Deep": {
		EventLoader.EventID.PLASMA_INCARNATE : 2.0,
		EventLoader.EventID.POWER_SURGE : 1.0,
		EventLoader.EventID.SPACE_RAY : 1.0,
		EventLoader.EventID.FLUCTUATION_UP : 1.0,
		EventLoader.EventID.SHINY : 1.0,
		EventLoader.EventID.GOODWILL : 1.0,
	},
}


static func get_event_pool_by_name(pool_name: String) -> EventPool:
	var weights : Dictionary = library.get(pool_name, {});
	var weights_typed := Dictionary(weights, TYPE_INT, &"", null, TYPE_FLOAT, &"", null);
	var pool : EventPool = EventPool.get_pool_from_weights(weights_typed);
	return pool;


func _init() -> void:
	push_error("don't do that, this is a static class");
