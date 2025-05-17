extends GenericEvent
class_name FlyEvent


var event_bg_per_layer : Dictionary = {
	MapState.HyperspaceDepth.NONE : preload("res://assets/graphics/event.png"),
	MapState.HyperspaceDepth.SHALLOW : preload("res://assets/graphics/event2.png"),
	MapState.HyperspaceDepth.NORMAL : preload("res://assets/graphics/event3.png"),
	MapState.HyperspaceDepth.DEEP : preload("res://assets/graphics/event4.png"),
};

var slots : Dictionary[GameState.TokenType, Texture2D] = {
	GameState.TokenType.CREWMATE: preload("res://assets/graphics/human.png"),
	GameState.TokenType.SHIP_NAVIGATION: preload("res://assets/graphics/nav.png"),
	GameState.TokenType.INGOT: preload("res://assets/graphics/metal.png"),
};


@export var event_text : String = "";
@export var event_title : String = "";
@export var event_image : Texture2D = null;

var input_row_scene : PackedScene = load("res://scenes/scene_elements/event_input_row.tscn");

var event_rows : Array[EventInputRow] = [];
var input_data : Array[GenericInputPanel.InputRowData] = [];

var callable_reset : Array = [];

var is_consumed : EventPool.EventLimitType = EventPool.EventLimitType.NOT_LIMITED;


func spawn_input_rows() -> void:
	for zone_idx in input_data.size():
		if event_rows.size() <= zone_idx:
			_spawn_input_row();
		_setup_input_row(zone_idx);
	
	if $InputContainer != null:
		if input_data.size() == 0:
			$InputContainer.hide();
		else:
			var final_pos = $InputContainer.position;
			$InputContainer.position += $InputContainer.hide_delta;
			var tween = create_tween();
			tween.tween_property($InputContainer, ^"position", final_pos, 0.2);


func get_event_zones() -> Array:
	return event_rows.map(
		# Error "nonexistent function get_zone in base Nil" if click continue a lot
		func(row: Node) -> EventZone: return row.get_zone();
	).filter(
		func(zone: EventZone) -> bool: return zone != null;
	);


func _spawn_input_row() -> void:
	var row = input_row_scene.instantiate();
	event_rows.push_back(row);
	$InputContainer/InputRowsContainer.add_child(row);


func _setup_input_row(i: int) -> void:
	var row := event_rows[i];
	var data := input_data[i];
	row.show();
	
	var input := row.get_zone();
	assert(input != null, "input is null, won't be usable");
	
	input.accepted_card_types.clear();
	input.accepted_card_types.push_back(data.type);
	input.accepts_stacks = data.is_stacking;
	input.stack_limit = data.stack_limit;
	
	var label := row.get_label();
	assert(label != null, "label is null, won't display text");
	
	var img := row.get_sprite();
	assert(img != null, "img is null, won't display slot graphic");
	
	var on_insert := data.callable_insert;
	var on_takeout := data.callable_takeout;
	
	if not on_insert.is_null():
		input.card_recieved.connect(on_insert);
		callable_reset.push_back([on_insert, input.card_recieved]);
	
	if not on_takeout.is_null():
		input.card_lost.connect(on_takeout);
		callable_reset.push_back([on_takeout, input.card_lost]);
	
	img.texture = slots[data.type];
	label.text = data.label;


func reset_event_inputs() -> void:
	input_data.clear();


func setup_event_input(token: GameState.TokenType, label: String, stacks := false, limit := 10) -> int:
	var i := input_data.size();
	var data := GenericInputPanel.InputRowData.new();
	
	data.type = token;
	data.is_stacking = stacks;
	data.stack_limit = limit;
	data.label = label;
	
	input_data.push_back(data);
	return i;


func setup_event_signals(
		i: int,
		card_insert : Callable = Callable(),
		card_takeout  : Callable = Callable(),
	) -> void:
		if i >= input_data.size():
			push_error("setting event inputs for an unexisting input");
			return;
		
		input_data[i].callable_insert = card_insert;
		input_data[i].callable_takeout = card_takeout;


func get_inputs_test_iterator() -> Array[Dictionary]:
	var iterator : Array[Dictionary] = [];
	
	# empty inputs
	iterator.push_back({"prep_times": 0, "before_idx": -1, "after_idx": -1});
	
	for idx in input_data.size():
		var stack_limit = input_data[idx].stack_limit if input_data[idx].is_stacking else 1;
		for count in stack_limit:
			iterator.push_back(
				{"prep_times": count + 1, "before_idx": idx, "after_idx": idx}
			);
	
	return iterator;


func _ready() -> void:
	if event_text != "" and $VBoxContainer/Label != null:
		super.text_anim($VBoxContainer/Label);
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
