extends GenericEvent
class_name FlyEvent


var event_bg_per_layer : Dictionary = {
	MapState.HyperspaceDepth.NONE : preload("res://assets/graphics/event.png"),
	MapState.HyperspaceDepth.SHALLOW : preload("res://assets/graphics/event2.png"),
	MapState.HyperspaceDepth.NORMAL : preload("res://assets/graphics/event3.png"),
	MapState.HyperspaceDepth.DEEP : preload("res://assets/graphics/event4.png"),
};

var slots : Dictionary = {
	GameState.TokenType.CREWMATE: preload("res://assets/graphics/human.png"),
	GameState.TokenType.SHIP_NAVIGATION: preload("res://assets/graphics/nav.png"),
	GameState.TokenType.INGOT: preload("res://assets/graphics/metal.png"),
};


@export var event_text : String = "";
@export var event_title : String = "";
@export var event_image : Texture2D = null;

var input_row_scene : PackedScene = load("res://scenes/scene_elements/event_input_row.tscn");

@export var event_rows : Array[Node] = [];
@export var event_zone_types : Array[GameState.TokenType] = [];
@export var event_zone_stacks : Array[bool] = [];
@export var event_zone_limits : Array[int] = [];
@export var event_zone_labels : Array[String] = [];

var event_callables_in : Array = [];
var event_callables_out : Array = [];

var callable_reset : Array = [];

var is_consumed : EventPool.EventLimitType = EventPool.EventLimitType.NOT_LIMITED;


func spawn_input_rows() -> void:
	if event_zone_types.size() != event_zone_stacks.size() or\
		event_zone_stacks.size() != event_zone_limits.size() or\
		event_zone_limits.size() != event_callables_in.size() or\
		event_callables_in.size() != event_callables_out.size():
			push_error("incorrect event setup: input parameters count not equal");
	
	for zone_idx in event_zone_types.size():
		if event_rows.size() <= zone_idx:
			_spawn_input_row();
		_setup_input_row(zone_idx);


func get_event_zones() -> Array:
	return event_rows.map(func(row: Node) -> EventZone: return row.get_node(^"EventZone"));


func _spawn_input_row() -> void:
	var row = input_row_scene.instantiate();
	event_rows.push_back(row);
	$InputRowsContainer.add_child(row);


func _setup_input_row(i: int) -> void:
	var row = event_rows[i];
	
	if i >= event_zone_types.size() or row == null:
		row.hide();
		return;
	
	row.show();
	
	var input = row.get_node("EventZone") as EventZone;
	assert(input != null, "input is null, won't be usable");
	
	input.accepted_card_types.clear();
	input.accepted_card_types.push_back(event_zone_types[i]);
	input.accepts_stacks = event_zone_stacks[i];
	input.stack_limit = event_zone_limits[i];
	
	var label = row.get_node("Label") as Label;
	assert(label != null, "label is null, won't display text");
	
	var img = input.get_node("CardSlotImage") as Sprite2D;
	assert(label != null, "img is null, won't display slot graphic");
	
	var on_insert = event_callables_in[i];
	var on_takeout = event_callables_out[i];
	
	if on_insert != null:
		input.card_recieved.connect(on_insert);
		callable_reset.push_back([on_insert, input.card_recieved]);
	
	if on_takeout != null:
		input.card_lost.connect(on_takeout);
		callable_reset.push_back([on_takeout, input.card_lost]);
	
	img.texture = slots[event_zone_types[i]];
	label.text = event_zone_labels[i];



func reset_event_inputs() -> void:
	event_zone_types.clear();


func setup_event_input(token: GameState.TokenType, label: String, stacks := false, limit := 10) -> int:
	var i = event_zone_types.size();
	
	event_zone_types.push_back(token);
	event_zone_stacks.push_back(stacks);
	event_zone_limits.push_back(limit);
	event_zone_labels.push_back(label);
	
	return i;


func setup_event_signals(i: int, card_insert = null, card_takeout = null) -> void:
	if i >= event_callables_in.size():
		var is_ok_in = event_callables_in.resize(i + 1);
		if is_ok_in != OK:
			push_error(error_string(is_ok_in));
		
		var is_ok_out = event_callables_out.resize(i + 1);
		if is_ok_out != OK:
			push_error(error_string(is_ok_out));
	
	event_callables_in[i] = card_insert;
	event_callables_out[i] = card_takeout;


func get_inputs_test_iterator() -> Array[Dictionary]:
	var iterator : Array[Dictionary] = [];
	
	# empty inputs
	iterator.push_back({"prep_times": 0, "before_idx": -1, "after_idx": -1});
	
	for idx in event_zone_types.size():
		var stack_limit = event_zone_limits[idx] if event_zone_stacks[idx] else 1;
		for count in stack_limit:
			iterator.push_back(
				{"prep_times": count + 1, "before_idx": idx, "after_idx": idx}
			);
	
	return iterator;


func _ready() -> void:
	if event_text != "" and $VBoxContainer/Label != null:
		$VBoxContainer/Label.text = event_text;
	
	if event_title != "" and $VBoxContainer/Title != null:
		$VBoxContainer/Title.text = event_title.to_upper();
	
	if event_image != null and $EventImage != null:
		$EventImage.texture = event_image;
	
	if GameState != null and GameState.map != null and $LevelHint != null:
		$LevelHint.text = "EVENT | DEPTH LVL%d" % (GameState.map.layer + 1);
	
	if GameState != null and GameState.map != null and $Sprite != null:
		$Sprite.texture = event_bg_per_layer[GameState.map.layer];
	
	spawn_input_rows();
