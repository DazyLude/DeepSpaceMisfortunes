extends Node2D
class_name GenericEvent


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

@onready var event_zones : Array = [
	$VBoxContainer/EventInputRow1/EventZone,
	$VBoxContainer/EventInputRow2/EventZone,
	$VBoxContainer/EventInputRow3/EventZone
];
@export var event_zone_types : Array[GameState.TokenType] = [];
@export var event_zone_stacks : Array[bool] = [false, false, false];
@export var event_zone_limits : Array[int] = [10, 10, 10];
@export var event_zone_labels : Array[String] = ["option 1", "option 2", "option 3"];

var event_callables : Array = [null, null, null, null, null, null];
var callable_reset : Array = [];

var is_consumed : EventPool.EventLimitType = EventPool.EventLimitType.NOT_LIMITED;


func reset_event_inputs() -> void:
	event_zone_types.clear();


func setup_event_input(token: GameState.TokenType, label: String, stacks := false, limit := 10) -> int:
	var i = event_zone_types.size();
	
	event_zone_types.push_back(token);
	event_zone_stacks[i] = stacks;
	event_zone_limits[i] = limit;
	event_zone_labels[i] = label;
	
	return i;


func setup_event_signals(i: int, card_insert = null, card_takeout = null) -> void:
	event_callables[i * 2] = card_insert;
	event_callables[i * 2 + 1] = card_takeout;


func reset_input_connections() -> void:
	for callable_signal_pair in callable_reset:
		callable_signal_pair[1].disconnect(callable_signal_pair[0]);
	
	callable_reset.clear();


func get_inputs_test_iterator() -> Array[Dictionary]:
	var iterator : Array[Dictionary] = [];
	
	# empty inputs
	iterator.push_back({"prep_times": 0, "before_idx": -1, "after_idx": -1})
	
	for idx in event_zone_types.size():
		var stack_limit = event_zone_limits[idx] if event_zone_stacks[idx] else 1;
		for count in stack_limit:
			iterator.push_back(
				{"prep_times": count + 1, "before_idx": idx * 2, "after_idx": idx * 2 + 1}
			);
	
	return iterator;


func _can_play() -> bool:
	return true;


func _action() -> void:
	push_warning("Placeholder event action played. Overload it.");


## called every time the scene instance is requested via EventLoader
func _prepare() -> void:
	pass;


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
	
	reset_input_connections();
	
	var rows := [$VBoxContainer/EventInputRow1, $VBoxContainer/EventInputRow2, $VBoxContainer/EventInputRow3];
	for i in rows.size():
		var row = rows[i];
		
		if i >= event_zone_types.size() or row == null:
			row.hide();
			continue;
		
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
		
		var on_insert = event_callables[2 * i];
		var on_takeout = event_callables[2 * i + 1];
		
		if on_insert != null:
			input.card_recieved.connect(on_insert);
			callable_reset.push_back([on_insert, input.card_recieved]);
		
		if on_takeout != null:
			input.card_lost.connect(on_takeout);
			callable_reset.push_back([on_takeout, input.card_lost]);
		
		img.texture = slots[event_zone_types[i]];
		label.text = event_zone_labels[i];
