extends GenericCard
class_name GenericEvent


enum LimitedType {
	NOT_LIMITED,
	LIMITED_PER_LAYER,
	LIMITED_GLOBALLY,
};


@export var event_text : String = "";
@export var event_title : String = "";
@export var event_image : Texture2D = null;

@onready var event_zones : Array = [
	$VBoxContainer/EventInputRow1/EventZone,
	$VBoxContainer/EventInputRow2/EventZone,
	$VBoxContainer/EventInputRow3/EventZone
];
@export var event_zone_types : Array[Table.TokenType] = [];
@export var event_zone_stacks : Array[bool] = [false, false, false];
@export var event_zone_limits : Array[int] = [10, 10, 10];
@export var event_zone_labels : Array[String] = ["option 1", "option 2", "option 3"];

var is_consumed : LimitedType = LimitedType.NOT_LIMITED;


func reset_event_inputs() -> void:
	event_zone_types.clear();


func setup_event_input(token: Table.TokenType, label: String, stacks := false, limit := 10):
	var i = event_zone_types.size();
	event_zone_types.push_back(token);
	event_zone_stacks[i] = stacks;
	event_zone_limits[i] = limit;
	event_zone_labels[i] = label;


func _can_play() -> bool:
	return true;


func _action() -> void:
	push_warning("Placeholder event action played. Overload it.");


func _init() -> void:
	can_have_shadow = false;


func _ready() -> void:
	if event_text != "" and $VBoxContainer/Label != null:
		$VBoxContainer/Label.text = event_text;
	
	if event_title != "" and $VBoxContainer/Title != null:
		$VBoxContainer/Title.text = event_title;
	
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
		
		assert(input != null, "label is null, won't display text");
		var label = row.get_node("Label") as Label;
		
		label.text = event_zone_labels[i];
