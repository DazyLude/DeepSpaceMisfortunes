extends GenericCard
class_name GenericEvent


@export var event_image : Texture2D = null;
@export var event_text : String = "";


var has_input : bool = false;

### key - button label, value - action
#var input_options : Dictionary[String, GenericEvent] = {};
## key - predicate (true if card leads to this outcome), value - action
var card_options : Dictionary[Callable, GenericEvent] = {};


func _action() -> void:
	#GameState.увеличить_разрыв_ануса();
	pass;
