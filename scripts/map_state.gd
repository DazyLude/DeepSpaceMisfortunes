extends RefCounted
class_name MapState


enum HyperspaceDepth {
	NONE, # NULL
	SHALLOW, # ALPHA
	NORMAL, # BETA
	DEEP, # GAMMA
	DELTA,
};


var round : int;
var layer : HyperspaceDepth;
var position : float;

var start_to_finish_distance : float;

var enter_layer : HyperspaceDepth;
var exit_points : Array[MapMarker] = [];

var layer_pools : Dictionary[HyperspaceDepth, EventPool] = {};

var layers_event_schedule : Dictionary[HyperspaceDepth, EventSchedule] = {};
var global_event_schedule := EventSchedule.new();

# TODO
var stationary_events : Array[MapMarker] = [];
var roaming_events : Dictionary[MapMarker, float] = {};

# not referencing GameStates rng directly to decouple classes.
# GameState's rng can be set after initialization.
var rng_ref : RandomNumberGenerator = null :
	get:
		if rng_ref == null:
			push_warning(
				"Creating placeholder random number generator.\n",
				"It is ok during tests, but not ok during the game."
			);
			rng_ref = RandomNumberGenerator.new();
		return rng_ref;


func set_rng_ref(ref: RandomNumberGenerator) -> MapState:
	rng_ref = ref;
	
	return self;


func is_marker_encounter_based(marker: MapMarker) -> bool:
	return marker._from == marker._to;


func should_draw_roaming_then_roam(marker: MapMarker, by: float) -> bool:
	marker._from += by;
	marker._to += by;
	
	return false;


func should_draw_stationary(
	marker: MapMarker,
	travel_from: float,
	travel_to: float,
) -> bool:
	return false;


func advance_rounds() -> void:
	round += 1;


func free_move(move_by: MovementCommand) -> void:
	if move_by == null:
		return;
	
	var delta = move_by._speed * move_by._move_direction;
	position = clampf(position + delta, 0.0, start_to_finish_distance);
	
	layer = move_by._move_to_layer;


func move_and_draw_scheduled_events(move_by: MovementCommand) -> Array[EventLoader.EventID]:
	var events : Array[EventLoader.EventID] = [];
	
	free_move(move_by);
	
	events.append_array(layers_event_schedule[layer].get_rounds_schedule(round));
	events.append_array(global_event_schedule.get_rounds_schedule(round));
	
	return events;


func is_at_finish_wrong_layer() -> bool:
	return false;


func pull_random_event() -> Result:
	var pool := layer_pools.get(layer, null) as EventPool;
	
	if pool == null:
		return Result.wrap_err("no pool to draw from");
	
	var event := pool.pull_random_event(rng_ref);
	
	return Result.wrap_ok(event);


func add_pool(layer: HyperspaceDepth, pool: EventPool) -> MapState:
	layer_pools[layer] = pool;
	
	return self; 


func _init(starting_layer: HyperspaceDepth, run_distance: float) -> void:
	self.round = 0;
	self.layer = starting_layer;
	self.enter_layer = starting_layer;
	self.position = 0.0;
	self.start_to_finish_distance = run_distance;
	
	for layer in HyperspaceDepth.values():
		layers_event_schedule[layer] = EventSchedule.new();


class MovementCommand extends RefCounted:
	var _move_to_layer : HyperspaceDepth;
	var _move_direction : int; # either of -1, 0, 1
	var _speed : float;
	
	
	func _init(speed: float, move_direction: int, new_depth: HyperspaceDepth) -> void:
		self._move_direction = signi(move_direction);
		self._move_to_layer = new_depth;
		self._speed = speed;


class MapMarker extends RefCounted:
	var event_id : EventLoader.EventID;
	
	var _layer : HyperspaceDepth; 
	var _from : float = 0.0;
	var _to : float = 0.0;
	var _encounter_probability : float = 1.0;
	
	# rendering parameters
	var is_visible : bool = false;
	var sprite : Texture2D = null;
	
	
	func set_sprite(new_sprite: Texture2D) -> MapMarker:
		is_visible = true;
		self.sprite = new_sprite;
		
		return self;
	
	
	func _init(
			event: EventLoader.EventID,
			layer: HyperspaceDepth,
			from : float,
			to : float = -1.0,
			encounter_probability : float = 1.0
		) -> void:
			self._event_id = event;
			self._layer = layer;
			self._from = from;
			
			if to == -1.0:
				self._to = from;
			else:
				self._to = to;
			
			self.__encounter_probability = clampf(encounter_probability, 0.0, 1.0);

## a simple object to bypass nested typed collection limitation
class EventSchedule extends RefCounted:
	var _schedule : Dictionary[int, Array];
	
	
	func get_rounds_schedule(round: int) -> Array[EventLoader.EventID]:
		return Array(_schedule.get_or_add(round, []), TYPE_INT, &"", null);
	
	
	func add_event(round: int, event: EventLoader.EventID) -> void:
		_schedule.get_or_add(round, []).push_back(event);


class MapEffect extends RefCounted:
	var event_id: EventLoader.EventID;
	
	var delay : int;
	var remaining_delay : int;
	var is_one_shot : bool;
