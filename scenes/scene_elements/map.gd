extends Control

@onready
var minimized_ship := $MinimizedDisplay/ShipProgressIcon;
@onready
var minimized_predictor := $MinimizedDisplay/ShipPredictIcon;
@onready
var maximized_ship := $MaximizedDisplay/ShipProgressIcon;
@onready
var maximized_predictor := $MaximizedDisplay/ShipPredictIcon;

var positions_per_layer : Dictionary = {
	MapState.HyperspaceDepth.NONE: [Vector2(0.0, 5.0), Vector2(415.0, 5.0)],
	MapState.HyperspaceDepth.SHALLOW: [Vector2(0.0, 37.0), Vector2(415.0, 37.0)],
	MapState.HyperspaceDepth.NORMAL: [Vector2(0.0, 69.0), Vector2(415.0, 69.0)],
	MapState.HyperspaceDepth.DEEP: [Vector2(0.0, 101.0), Vector2(415.0, 101.0)],
	MapState.HyperspaceDepth.DELTA: [Vector2(0.0, 133.0), Vector2(415.0, 133.0)],
}


func move_ship_markers(_dummy = null) -> void:
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
	GameState.new_move_command.connect(move_ship_markers);
	GameState.new_phase.connect(move_ship_markers);
