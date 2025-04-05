extends Node2D
class_name GenericCard


signal picked;
signal dropped;


@export var card_texture : Texture2D = null;


var is_hovered : bool = false;


@onready var sprite : Sprite2D = $Sprite;
@onready var hitbox : Area2D = $Hitbox;
@onready var hitbox_shape : CollisionShape2D = $Hitbox/HitboxRect;


func hover() -> void:
	is_hovered = true;


func unhover() -> void:
	is_hovered = false;


func setup_hitbox() -> void:
	hitbox_shape.shape.size = sprite.get_rect().size;
	hitbox.position = sprite.position;
	
	hitbox.mouse_entered.connect(hover);
	hitbox.mouse_exited.connect(unhover);


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_btn_event := event as InputEventMouseButton;
		match mouse_btn_event.button_index:
			MOUSE_BUTTON_LEFT when is_hovered and mouse_btn_event.pressed:
				picked.emit();
			MOUSE_BUTTON_LEFT when is_hovered and not mouse_btn_event.pressed:
				dropped.emit();


func _ready() -> void:
	if card_texture != null:
		sprite.texture = card_texture;
	
	setup_hitbox();
