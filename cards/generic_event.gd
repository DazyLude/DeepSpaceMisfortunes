extends GenericCard
class_name GenericEvent

enum LimitedType {
	NOT_LIMITED,
	LIMITED_PER_LAYER,
	LIMITED_GLOBALLY,
};


@export var event_image : Texture2D = null;
@export var event_text : String = "";

var is_consumed : LimitedType = LimitedType.NOT_LIMITED;

### key - button label, value - action
#var input_options : Dictionary[String, GenericEvent] = {};
### key - predicate (true if card leads to this outcome), value - action
#var card_options : Dictionary[Callable, GenericEvent] = {};


func _action(_board: Table) -> void:
	push_warning("Placeholder event action played. Overload it.");


func _ready() -> void:
	setup_hitbox();
