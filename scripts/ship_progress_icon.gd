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
	
	if predict:
		distance = min(GameState.TRAVEL_GOAL, GameState.travel_distance + GameState.get_speed());
	else:
		distance = min(GameState.TRAVEL_GOAL, GameState.travel_distance);
	
	var progress = distance / GameState.TRAVEL_GOAL;
	tween.tween_property(self, "position",
		Vector2(start_x + progress_bar_len * progress, 5), 1.0)\
		.set_trans(Tween.TRANS_QUAD);


func _ready() -> void:
	GameState.new_phase.connect(_advance);
