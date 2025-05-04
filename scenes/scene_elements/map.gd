extends Control

@onready
var minimized_ship := $MinimizedDisplay/Ship/ProgressIcon;
@onready
var minimized_predictor := $MinimizedDisplay/Ship/PredictIcon;
@onready
var maximized_ship := $MaximizedDisplay/Ship/ProgressIcon;
@onready
var maximized_predictor := $MaximizedDisplay/Ship/PredictIcon;

@onready
var markers_parent = $MaximizedDisplay/Markers;

const DELTA_Y : float = 31.0;
const MARKER_SIZE := Vector2(32.0, 32.0);

var positions_per_layer : Dictionary = {
	MapState.HyperspaceDepth.NONE: [Vector2(0.0, 5.0), Vector2(415.0, 5.0)],
	MapState.HyperspaceDepth.SHALLOW: [Vector2(0.0, 37.0), Vector2(415.0, 37.0)],
	MapState.HyperspaceDepth.NORMAL: [Vector2(0.0, 69.0), Vector2(415.0, 69.0)],
	MapState.HyperspaceDepth.DEEP: [Vector2(0.0, 101.0), Vector2(415.0, 101.0)],
	MapState.HyperspaceDepth.DELTA: [Vector2(0.0, 133.0), Vector2(415.0, 133.0)],
}


func get_map_position(at: float, layer: MapState.HyperspaceDepth = MapState.HyperspaceDepth.NONE) -> Vector2:
	var vectors = positions_per_layer[layer];
	return vectors[0].lerp(vectors[1], at);


func render_exit_markers() -> void:
	for child in markers_parent.get_children():
		markers_parent.remove_child(child);
		child.queue_free();
	
	if GameState.map == null:
		return;
	
	for marker in GameState.map.exit_points:
		var texture = marker.sprite;
		if texture != null and marker.is_visible:
			var texture_rect := TextureRect.new();
			
			texture_rect.size = MARKER_SIZE;
			texture_rect.texture = texture;
			texture_rect.expand_mode = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE;
			
			var progress = marker._from / GameState.map.start_to_finish_distance;
			texture_rect.position = get_map_position(progress, marker._layer);
			
			markers_parent.add_child(texture_rect);


func update_ship_markers(_dummy = null) -> void:
	self.visible = not GameState.map == null;
	if GameState.map == null:
		return;
	
	maximized_ship.start_pos = positions_per_layer[GameState.map.layer][0];
	maximized_ship.end_pos = positions_per_layer[GameState.map.layer][1];
	
	if GameState.move_command != null:
		var move_command = GameState.move_command;
		
		maximized_predictor.start_pos = positions_per_layer[move_command._move_to_layer][0];
		maximized_predictor.end_pos = positions_per_layer[move_command._move_to_layer][1];
	else:
		maximized_predictor.start_pos = maximized_ship.start_pos;
		maximized_predictor.end_pos = maximized_ship.end_pos;
	
	minimized_ship._advance();
	minimized_predictor._advance();
	maximized_ship._advance();
	maximized_predictor._advance();


func _ready() -> void:
	GameState.new_move_command.connect(update_ship_markers);
	GameState.new_phase.connect(update_ship_markers);
	GameState.new_map.connect(update_ship_markers);
	GameState.new_map.connect(render_exit_markers);
