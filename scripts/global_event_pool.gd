extends Node


## loads and instantiates GenericEvent scenes
enum EventID {
	GENERIC,
	
	# special
	MAIN_MENU,
	TUTORIAL_INTRO,
	TUTORIAL_EVENTS,
	TUTORIAL_TOKENS,
	TUTORIAL_SYSTEMS,
	TUTORIAL_DAMAGE_BASIC,
	TUTORIAL_GAME_PROGRESSION,
	TUTORIAL_LOSE_CONDITION,
	TUTORIAL_WIN_CONDITION,
	TUTORIAL_MANNING,
	TUTORIAL_DAMAGE_ELECTRIC,
	TUTORIAL_DAMAGE_NORMAL,
	TUTORIAL_END,
	
	# default gameplay loop events
	SHIP_NAVIGATION,
	PROGRESS_REPORT,
	SHIP_ACTION,
	
	GAMEOVER,
	VICTORY,
	
	# continuations of other events
	FRIEND2,
	
	# random bad events
	NOTHING,
	ASTEROID,
	LARGE_ASTEROID,
	POWER_SURGE,
	PLASMA_INCARNATE,
	SPACE_RAY,
	FLUCTUATION_UP,
	FLUCTUATION_DOWN,
	ALIENS,
	
	# random neutral
	SHINY,
	TIME_DILATION,
	
	# random good
	GOODWILL,
	FRIEND,
};


var event_load_params : Dictionary[EventID, String] = {
	EventID.GENERIC: "res://cards/generic_event.tscn",
	
	EventID.MAIN_MENU: "res://cards/events/menu.gd",
	
	EventID.TUTORIAL_INTRO: "res://cards/events/tutorial.gd",
	EventID.TUTORIAL_EVENTS: "res://cards/events/tutorial_events.gd",
	EventID.TUTORIAL_TOKENS: "res://cards/events/tutorial_tokens.gd",
	EventID.TUTORIAL_SYSTEMS: "res://cards/events/tutorial_systems.gd",
	EventID.TUTORIAL_DAMAGE_BASIC: "res://cards/events/tutorial_damage_basic.gd",
	EventID.TUTORIAL_GAME_PROGRESSION: "res://cards/events/tutorial_progression.gd",
	EventID.TUTORIAL_LOSE_CONDITION: "res://cards/events/tutorial_lose_condition.gd",
	EventID.TUTORIAL_WIN_CONDITION: "res://cards/events/tutorial_win_condition.gd",
	EventID.TUTORIAL_MANNING: "res://cards/events/tutorial_manning.gd",
	EventID.TUTORIAL_DAMAGE_ELECTRIC: "res://cards/events/tutorial_electric_damage.gd",
	EventID.TUTORIAL_DAMAGE_NORMAL: "res://cards/events/tutorial_physical_damage.gd",
	EventID.TUTORIAL_END: "res://cards/events/tutorial_wrap_up.gd",
	
	EventID.SHIP_NAVIGATION: "res://cards/events/ship_navigation.gd",
	EventID.PROGRESS_REPORT: "res://cards/events/ship_progress.gd",
	EventID.SHIP_ACTION: "res://cards/events/ship_action.gd",
	
	EventID.GAMEOVER: "res://cards/events/gameover.gd",
	EventID.VICTORY: "res://cards/events/victory.gd",
	
	EventID.NOTHING: "res://cards/events/space_is_empty.gd",
	EventID.ASTEROID: "res://cards/events/asteroid.gd",
	EventID.LARGE_ASTEROID: "res://cards/events/large_asteroid.gd",
	EventID.POWER_SURGE: "res://cards/events/power_surge.gd",
	EventID.PLASMA_INCARNATE: "res://cards/events/plasma_guy.gd",
	EventID.SPACE_RAY: "res://cards/events/space_beam.gd",
	EventID.FLUCTUATION_UP: "res://cards/events/fluctuation_up.gd",
	EventID.FLUCTUATION_DOWN: "res://cards/events/fluctuation_down.gd",
	EventID.ALIENS: "res://cards/events/ayyy_lmao.gd",
	
	EventID.SHINY: "res://cards/events/shiny.gd",
	EventID.TIME_DILATION: "res://cards/events/double_time.gd",
	
	EventID.GOODWILL: "res://cards/events/good_will.gd",
	EventID.FRIEND: "res://cards/events/friend1.gd",
	EventID.FRIEND2: "res://cards/events/friend2.gd",
};


var event_instances : Dictionary[EventID, GenericEvent];


func get_event_instance(id: EventID) -> GenericEvent:
	var instance := event_instances.get(id, null) as GenericEvent;
	return instance;


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
