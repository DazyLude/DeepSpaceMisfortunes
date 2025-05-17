extends Node2D
class_name GenericEvent


var animated_object = null;
var text_anim_tween : Tween;
var text_anim_speed : float = 2.0;
signal text_anim_finished;


func _can_play() -> bool:
	return true;


func _action() -> void:
	push_warning("Placeholder event action played. Overload it.");
	

func text_anim(obj) -> void:
	if text_anim_tween:
		text_anim_tween.kill();
	text_anim_tween = create_tween();
	animated_object = obj;
	text_anim_tween.tween_property(obj, "visible_ratio", 1.0, text_anim_speed).from(0.0);
	text_anim_tween.tween_callback(_on_tween_finished);


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(text_anim_tween):
			text_anim_tween.kill()
		if animated_object != null:
			animated_object.visible_ratio = 1.0;
			animated_object = null;


func _on_tween_finished() -> void:
	text_anim_finished.emit();


## called every time the scene instance is requested via EventLoader
func _prepare() -> void:
	pass;
