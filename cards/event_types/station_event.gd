extends GenericEvent
class_name StationEvent


func _can_play() -> bool:
	return false;


func _action() -> void:
	pass;


func _prepare() -> void:
	pass;


func _ready() -> void:
	if $Button != null and GameState != null:
		$Button.pressed.connect(GameState.advance_phase);
		GameState.load_map();
		
	super.text_anim($Label2);
