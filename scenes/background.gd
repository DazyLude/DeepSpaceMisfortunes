extends Node2D


const backgrounds_per_layer : Dictionary[GameStateClass.HyperspaceDepth, Texture2D] = {
	GameStateClass.HyperspaceDepth.NONE: preload("res://assets/background/layer_1.png"),  
	GameStateClass.HyperspaceDepth.SHALLOW: preload("res://assets/background/layer_2.png"),
	GameStateClass.HyperspaceDepth.NORMAL: preload("res://assets/background/layer_3.png"), 
	GameStateClass.HyperspaceDepth.DEEP: preload("res://assets/background/layer_4.png"),
};


var displayed_depth : GameStateClass.HyperspaceDepth;
var idle_tween : Tween = null;
var transition_tween : Tween = null;
var screen_size : Vector2;


func transition(_d) -> void:
	if displayed_depth == GameState.hyper_depth:
		return;
	if transition_tween:
		transition_tween.kill();
	transition_tween = create_tween();
	
	$Background.material.set_shader_parameter(&"second_texture", backgrounds_per_layer[GameState.hyper_depth]);
	$BackgroundNext.material.set_shader_parameter(&"second_texture", backgrounds_per_layer[GameState.hyper_depth]);
	
	transition_tween.parallel().tween_property($Background.material, "shader_parameter/threshold", 1.0, 1.0);
	transition_tween.parallel().tween_property($BackgroundNext.material, "shader_parameter/threshold", 1.0, 1.0);
	transition_tween.tween_callback(func():
		$Background.texture = backgrounds_per_layer[GameState.hyper_depth];
		$BackgroundNext.texture = backgrounds_per_layer[GameState.hyper_depth];
	);
	
	$Background.material.set_shader_parameter(&"threshold", 0.0);
	$BackgroundNext.material.set_shader_parameter(&"threshold", 0.0);

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
