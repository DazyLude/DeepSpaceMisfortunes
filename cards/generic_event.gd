extends Node2D
class_name GenericEvent


func _can_play() -> bool:
	return true;


func _action() -> void:
	push_warning("Placeholder event action played. Overload it.");


## called every time the scene instance is requested via EventLoader
func _prepare() -> void:
	pass;
