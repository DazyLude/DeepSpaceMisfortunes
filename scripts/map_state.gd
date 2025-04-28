extends RefCounted
class_name MapState


enum HyperspaceDepth {
	NONE,
	SHALLOW,
	NORMAL,
	DEEP,
	EXTRA,
};


var rounds_spent_on_map : int;
var map_total_distance : float;
var current_layer : HyperspaceDepth;

var map_layers;


# not referencing GameStates rng directly to decouple classes.
# GameState's rng can be set after initialization.
var rng_ref : RandomNumberGenerator = null :
	get:
		if rng_ref == null:
			push_warning(
				"Creating placeholder random number generator.",
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


class MapMarker extends RefCounted:
	var _event_id: EventLoader.EventID;
	
	var _from : float = 0.0;
	var _to : float = 0.0;
	var _encounter_probability : float = 1.0;
	
	var is_visible : bool = false;
	var sprite : Texture2D = null;
	
	
	func set_sprite(new_sprite: Texture2D) -> MapMarker:
		is_visible = true;
		self.sprite = new_sprite;
		
		return self;
	
	
	func _init(event: EventLoader.EventID, from : float, to : float = -1.0, encounter_probability : float = 1.0) -> void:
		self._event_id = event;
		self._from = from;
		
		if to == -1.0:
			self._to = from;
		else:
			self._to = to;
		
		self.__encounter_probability = encounter_probability;


class MapEffect extends RefCounted:
	var event_id: EventLoader.EventID;
	
	var delay : int;
	var remaining_delay : int;
	var is_one_shot : bool;
