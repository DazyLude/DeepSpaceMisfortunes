extends TextureRect

@export var predict : bool = false;

@onready var start_x = self.position.x;
const progress_bar_len = 415;
var tween = null;


func _advance(_dummy) -> void:
	if tween != null:
		tween.kill();
	tween = get_tree().create_tween();
	
	var distance;
	
	var start = 0.0;
	var finish = GameState.map.start_to_finish_distance;
	var current = GameState.map.position;
	
	if predict:
		distance = min(finish, current + GameState.get_speed());
	else:
		distance = min(finish, current);
	
	var progress = (distance - start) / (finish - start);
	tween.tween_property(self, "position",
		Vector2(start_x + progress_bar_len * progress, 5), 1.0)\
		.set_trans(Tween.TRANS_QUAD);


func _ready() -> void:
	GameState.new_phase.connect(_advance);
