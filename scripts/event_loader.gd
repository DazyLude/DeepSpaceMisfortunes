class_name EventLoader;


enum EventID {
	GENERIC,
	GENERIC_LIMITED,
	
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
	ASSIGN_REPAIRS,
	SHIP_NAVIGATION,
	
	NO_EVENTS,
	
	SHIP_ACTION,
	
	GAMEOVER,
	VICTORY,
	
	# continuations of other events
	FRIEND2,
	COSMOCOP2,
	COSMOCOP3,
	
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
	COSMOCOP,
	
	# random neutral
	SHINY,
	TIME_DILATION,
	
	# random good
	GOODWILL,
	FRIEND,
};


const event_load_params : Dictionary[EventID, String] = {
	EventID.GENERIC: "res://cards/generic_event.tscn",
	EventID.GENERIC_LIMITED: "res://cards/generic_limited_event.gd",
	
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
	EventID.ASSIGN_REPAIRS: "res://cards/events/ship_progress.gd",
	
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
	EventID.COSMOCOP: "res://cards/events/cosmocop1.gd",
	EventID.COSMOCOP2: "res://cards/events/cosmocop2.gd",
	EventID.COSMOCOP3: "res://cards/events/cosmocop3.gd",
	
	EventID.SHINY: "res://cards/events/shiny.gd",
	EventID.TIME_DILATION: "res://cards/events/double_time.gd",
	
	EventID.GOODWILL: "res://cards/events/good_will.gd",
	EventID.FRIEND: "res://cards/events/friend1.gd",
	EventID.FRIEND2: "res://cards/events/friend2.gd",
};


static func get_event_instance(event_id: EventID) -> Node2D:
	var path = event_load_params.get(event_id, "");
	var event : Node2D = null;
	
	if ResourceLoader.exists(path):
		match ResourceLoader.load(path):
			var event_scene when event_scene is PackedScene:
				event = load_from_packed_scene(event_scene);
			
			var event_script when event_script is Script:
				event = load_from_script(event_script);
	
	if event == null:
		push_error("event is null");
	
	return event;


static func load_from_packed_scene(event_scene: PackedScene) -> Node2D:
	if event_scene == null:
		push_error("event_scene is null"); 
		return null;
	
	var event = event_scene.instantiate();
	
	if not event is Node2D:
		event.free();
		push_error("resource is not a Node2D");
		return null;

	return event;


static func load_from_script(event_script: Script) -> Node2D:
	var scene : Node2D = ResourceLoader.load("res://cards/generic_event.tscn").instantiate();
	scene.set_script(event_script);
	
	return scene;
