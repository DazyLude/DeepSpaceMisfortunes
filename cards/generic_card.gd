extends Node2D
class_name GenericCard


signal picked;
signal dropped;


const fly_transition : float = 0.05;
const fly_offset := Vector2(-1.0, -1.0);
const max_blur : float = 1.5;
var transition_tween : Tween = null;


@export var card_texture : Texture2D = null;


var is_hovered : bool = false;


@onready var sprite : Sprite2D = $Sprite;
@onready var hitbox : Area2D = $Hitbox;
@onready var hitbox_shape : CollisionShape2D = $Hitbox/HitboxRect;

var can_have_shadow : bool = true;
var shadow_sprite : Sprite2D = null;


func hover() -> void:
	is_hovered = true;


func unhover() -> void:
	is_hovered = false;


func setup_hitbox() -> void:
	hitbox_shape.shape.size = sprite.get_rect().size * 0.75;
	hitbox.position = sprite.position;
	
	hitbox.mouse_entered.connect(hover);
	hitbox.mouse_exited.connect(unhover);


func fly_with_shadow() -> void:
	if transition_tween:
		transition_tween.kill();
	transition_tween = create_tween();
	
	shadow_sprite.material.set_shader_parameter(&"display", true);
	sprite.z_index = 1;
	
	transition_tween.tween_property(shadow_sprite, ^"material:shader_parameter/shadow_offset", fly_offset * 2, fly_transition);
	transition_tween.parallel().tween_property(shadow_sprite, ^"material:shader_parameter/blur_amount", max_blur, fly_transition);
	transition_tween.parallel().tween_property(sprite, ^"position", fly_offset, fly_transition);
	transition_tween.parallel().tween_property(shadow_sprite, ^"position", fly_offset, fly_transition);


func stop_flying() -> void:
	if transition_tween:
		transition_tween.kill();
	transition_tween = create_tween();
	
	transition_tween.tween_property(shadow_sprite, ^"material:shader_parameter/shadow_offset", Vector2(), fly_transition);
	transition_tween.parallel()\
		.tween_property(shadow_sprite, ^"material:shader_parameter/blur_amount", 0.0, fly_transition);
	transition_tween.parallel().tween_property(sprite, ^"position", Vector2(), fly_transition);
	transition_tween.parallel().tween_property(shadow_sprite, ^"position", Vector2(), fly_transition);
	
	transition_tween.tween_callback(shadow_sprite.material.set_shader_parameter.bind(&"display", false));
	transition_tween.tween_callback(func(): sprite.z_index = 0);


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_btn_event := event as InputEventMouseButton;
		match mouse_btn_event.button_index:
			MOUSE_BUTTON_LEFT when is_hovered and mouse_btn_event.pressed and visible:
				picked.emit();
				get_viewport().set_input_as_handled();
				
			MOUSE_BUTTON_LEFT when is_hovered and not mouse_btn_event.pressed and visible:
				dropped.emit();
				#get_viewport().set_input_as_handled();


func _ready() -> void:
	if card_texture != null:
		sprite.texture = card_texture;
	
	if can_have_shadow:
		shadow_sprite = $Sprite.duplicate();
		add_child(shadow_sprite);
		
		shadow_sprite.material = ShaderMaterial.new();
		shadow_sprite.material.shader = load("res://shaders/shadow.gdshader");
		shadow_sprite.material.set_shader_parameter(&"shadow_offset", Vector2());
		shadow_sprite.material.set_shader_parameter(&"blur_amount", 0.0);
	
	setup_hitbox();
