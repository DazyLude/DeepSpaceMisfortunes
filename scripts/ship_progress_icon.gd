extends TextureRect


@onready var start_x = self.position.x;
const progress_bar_len = 400;
var tween = null;


func _advance(_dummy) -> void:
	if tween != null:
		tween.kill();
	
	var progress = GameState.travel_distance / GameState.TRAVEL_GOAL;
	tween = get_tree().create_tween();
	tween.tween_property(self, "position", \
		Vector2(start_x + progress_bar_len * progress, 5), 1) \
		.set_trans(Tween.TRANS_QUAD);


func _ready() -> void:
	GameState.new_phase.connect(_advance);
