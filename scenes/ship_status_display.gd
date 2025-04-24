extends Control


func update_ship_status(_d: GameState.RoundPhase) -> void:
	if GameState.ship == null:
		return;
	
	var text = "";
	
	for ship_system_i in GameState.ship.system_hp:
		var system_name = ShipState.SystemRole.keys()[ship_system_i];
		var system_hp := GameState.ship.system_hp[ship_system_i];
		
		text += "%s: %d\n" % [system_name, system_hp];
	
	$Label.text = text;


func _ready() -> void:
	GameState.new_phase.connect(update_ship_status);
	update_ship_status(GameState.current_phase);
