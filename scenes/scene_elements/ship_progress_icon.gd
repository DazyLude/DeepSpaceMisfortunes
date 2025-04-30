extends TextureRect

@export var predict : bool = false;

@onready var start_pos := self.position;
var end_pos := Vector2(415.0, 5.0)

var tween = null;


func _advance() -> void:
	if tween != null:
		tween.kill();
	tween = get_tree().create_tween();
	
	var distance;
	
	var start = 0.0;
	var finish = GameState.map.start_to_finish_distance;
	var current = GameState.map.position;
	
	if predict:
		var move_command = GameState.move_command;
		if move_command != null:
			distance = min(finish, current + move_command._speed * move_command._move_direction);
		else:
			distance = min(finish, current);
	else:
		distance = min(finish, current);
	
	var progress = (distance - start) / (finish - start);
	tween.tween_property(
			self,
			"position",
			start_pos.lerp(end_pos, progress),
			1.0
		).set_trans(Tween.TRANS_QUAD);
