extends Node


## loads and instantiates GenericEvent scenes
enum EventID {
	GENERIC,
};


var event_load_params : Dictionary[EventID, String] = {
	EventID.GENERIC: "res://cards/generic_event.tscn"
};


var event_instances : Dictionary[EventID, GenericEvent];


func get_event_instance(id: EventID) -> GenericEvent:
	return event_instances.get(id, null);


func _init() -> void:
	for event_id in EventID.values():
		var path = event_load_params.get(event_id, "");
		if ResourceLoader.exists(path):
			var event_scene = ResourceLoader.load(path) as PackedScene;
			
			if event_scene == null:
				push_error("resource is not a scene: \"%s\" for id \"%s\"", [path, EventID.keys()[event_id]]); 
				continue;
			
			event_scene = event_scene.instantiate() as GenericEvent;
			
			if event_scene == null:
				push_error("resource is not a generic event: \"%s\" for id \"%s\"", [path, EventID.keys()[event_id]]);
				continue; 
			
			event_instances[event_id] = event_scene;
