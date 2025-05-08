extends Control
class_name GenericInputPanel


@export var hide_delta : Vector2;
@onready var shown_position : Vector2 = self.position;



class InputRowData extends RefCounted:
	var type = GameState.TokenType;
	var is_stacking : bool;
	var stack_limit : int;
	var label : String;
	
	var callable_insert : Callable;
	var callable_takeout : Callable;
