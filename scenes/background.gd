extends Node2D


const backgrounds_per_layer : Dictionary[GameStateClass.HyperspaceDepth, Texture2D] = {
	GameStateClass.HyperspaceDepth.NONE: preload("res://assets/background/layer_1.png"),  
	GameStateClass.HyperspaceDepth.SHALLOW: preload("res://assets/background/layer_2.png"),
	GameStateClass.HyperspaceDepth.NORMAL: preload("res://assets/background/layer_3.png"), 
	GameStateClass.HyperspaceDepth.DEEP: preload("res://assets/background/layer_4.png"),
};


var displayed_depth : GameStateClass.HyperspaceDepth;
var idle_tween : Tween = null;
var screen_size : Vector2;


func transition(_d) -> void:
	if displayed_depth == GameState.hyper_depth:
		return;
	
	# TODO можно написать шейдер, (или взять с https://godotshaders.com/)
	# который будет деформировать текстуру в момент перехода
	$Background.texture = backgrounds_per_layer[GameState.hyper_depth];
	$BackgroundNext.texture = backgrounds_per_layer[GameState.hyper_depth];
	
	displayed_depth = GameState.hyper_depth;


func setup_scale() -> void:
	var texture_size = $Background.texture.get_size();
	screen_size = get_viewport_rect().size;
	
	var proportion : float = screen_size.y / texture_size.y;
	
	scale = Vector2(proportion, proportion);


func _ready() -> void:
	setup_scale();
	$AnimationPlayer.play(&"idle", -1, 0.5);
	GameState.new_phase.connect(transition);
