extends Node


## loads and instantiates GenericEvent scenes
enum EventID {
	GENERIC,
	
	SHIP_NAVIGATION,
};


var event_load_params : Dictionary[EventID, String] = {
	EventID.GENERIC: "res://cards/generic_event.tscn",
	EventID.SHIP_NAVIGATION: "res://cards/events/ship_navigation.gd",
};


var event_instances : Dictionary[EventID, GenericEvent];


func get_event_instance(id: EventID) -> GenericEvent:
	return event_instances.get(id, null);


func _init() -> void:
	for event_id in EventID.values():
		var path = event_load_params.get(event_id, "");
		if ResourceLoader.exists(path):
			match ResourceLoader.load(path):
				var event_scene when event_scene is PackedScene:
					if event_scene == null:
						push_error("resource is not a scene: \"%s\" for id \"%s\"", [path, EventID.keys()[event_id]]); 
						continue;
					
					var event = event_scene.instantiate() as GenericEvent;
					
					if event_scene == null:
						push_error("resource is not a generic event: \"%s\" for id \"%s\"", [path, EventID.keys()[event_id]]);
						continue; 
					
					event_instances[event_id] = event;
				
				var event_script when event_script is Script:
					var scene : Node2D = ResourceLoader.load("res://cards/generic_event.tscn").instantiate();
					scene.set_script(event_script);
					
					event_instances[event_id] = scene;
