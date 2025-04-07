extends Node2D
class_name Ship;


@onready
var zone_to_system : Dictionary[GenericTableZone, GameState.ShipState.System] = {
	$LifeSupportSlot: GameState.ShipState.System.LIFE_SUPPORT,
	$NavigationSlot: GameState.ShipState.System.NAVIGATION,
	$AutopilotSlot: GameState.ShipState.System.AUTOPILOT,
	$InnerHullSlot: GameState.ShipState.System.INNER_HULL,
	$OuterHullSlot: GameState.ShipState.System.OUTER_HULL,
	$EnginesSlot: GameState.ShipState.System.ENGINES,
	$HyperSlot: GameState.ShipState.System.HYPER_ENGINES,
};

@onready
var icon_tweens : Dictionary[Node, Tween] = {
	$LifeSupportSlot/Background: null,
	$NavigationSlot/Background: null,
	$AutopilotSlot/Background: null,
	$InnerHullSlot/Background: null,
	$OuterHullSlot/Background: null,
	$EnginesSlot/Background: null,
	$HyperSlot/Background: null
}

@onready
var hp_per_system : Dictionary = {
	GameState.ShipState.System.NAVIGATION: $NavigationSlot/HP,
	GameState.ShipState.System.LIFE_SUPPORT: $LifeSupportSlot/HP,
	GameState.ShipState.System.INNER_HULL: $InnerHullSlot/HP, 
	GameState.ShipState.System.AUTOPILOT: $AutopilotSlot/HP,
	GameState.ShipState.System.ENGINES: $EnginesSlot/HP,
	GameState.ShipState.System.HYPER_ENGINES: $HyperSlot/HP, 
	GameState.ShipState.System.OUTER_HULL: $OuterHullSlot/HP,
}


const flare_time : float = 1.5;
var green_gradient = GradientTexture1D.new();
var red_gradient = GradientTexture1D.new();


func update_hp_display(_s) -> void:
	for system in GameState.ship.system_hp:
		hp_per_system[system].text = "%d" % GameState.ship.system_hp[system];


func get_active_zones() -> Array[GenericTableZone]:
	var zones : Array[GenericTableZone] = [];
	for c in self.get_children().filter(func(x): return x is EventZone):
		zones.push_back(c);

	return zones;


func hide_manned_icons() -> void:
	for system_slot in zone_to_system:
		var manned_icon := system_slot.get_node("Manned");
		manned_icon.hide();


func update_manned_icons() -> void:
	for system_slot in zone_to_system:
		var manned_icon := system_slot.get_node("Manned");
		var system := zone_to_system[system_slot];
		
		manned_icon.visible = GameState.ship.is_system_manned(system);


func on_system_damaged(system: GameState.ShipState.System) -> void:
	var system_node = zone_to_system.find_key(system);
	if system_node != null:
		var system_icon = system_node.get_node("Background");
		flare_red(system_icon);


func on_system_repaired(system: GameState.ShipState.System) -> void:
	var system_node = zone_to_system.find_key(system);
	if system_node != null:
		var system_icon = system_node.get_node("Background");
		flare_green(system_icon);


func update_warning_icon(_p) -> void:
	$Warning.visible = GameState.life_support_failure;


func _add_crewmate_to_system(card: GenericCard, zone: GenericTableZone) -> void:
	GameState.ship.man_system(
		GameState.active_table.active_cards[card], zone_to_system[zone]
	);


func _remove_crewmate_from_system(card: GenericCard) -> void:
	GameState.ship.stop_manning(GameState.active_table.active_cards[card]);


func flare_red(icon: Sprite2D) -> void:
	icon.material.set_shader_parameter(&"color", red_gradient);
	icon.material.set_shader_parameter(&"intensity", 0.0);
	
	if icon_tweens.get(icon, null):
		icon_tweens[icon].kill();
	
	var tween := create_tween();
	
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 1.0, flare_time)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT);
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 0.0, flare_time)\
		.set_ease(Tween.EASE_IN);
	
	icon_tweens[icon] = tween;


func flare_green(icon: Sprite2D) -> void:
	icon.material.set_shader_parameter(&"color", green_gradient);
	icon.material.set_shader_parameter(&"intensity", 0.0);
	
	if icon_tweens.get(icon, null):
		icon_tweens[icon].kill();
	
	var tween := create_tween();
	
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 1.0, flare_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 0.0, flare_time)\
		.set_ease(Tween.EASE_IN);
	
	icon_tweens[icon] = tween;


func set_icon_materials() -> void:
	for system_slot in zone_to_system:
		var icon := system_slot.get_node("Background");
		setup_icon_outline_shader(icon);


func setup_icon_outline_shader(icon: Sprite2D) -> void:
	var shader := preload("res://shaders/outline.gdshader");
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader;
	
	shader_material.set_shader_parameter(&"color", green_gradient);
	shader_material.set_shader_parameter(&"gradientResolution", 30);
	shader_material.set_shader_parameter(&"thickness", 3.5);
	shader_material.set_shader_parameter(&"tolerance", 0.9);
	shader_material.set_shader_parameter(&"intensity", 0.0);
	
	icon.material = shader_material;


func _ready() -> void:
	GameState.new_phase.connect(update_warning_icon);
	$Warning.hide();
	
	GameState.system_damaged.connect(on_system_damaged);
	GameState.system_repaired.connect(on_system_repaired);
	GameState.system_manned.connect(update_manned_icons);
	
	GameState.system_damaged.connect(update_hp_display);
	GameState.system_repaired.connect(update_hp_display);
	GameState.new_phase.connect(update_hp_display);
	
	green_gradient.gradient = preload("res://assets/green_gradient.tres");
	red_gradient.gradient = preload("res://assets/red_gradient.tres");
	
	set_icon_materials();
	hide_manned_icons();
	
	for zone in get_active_zones():
		zone.card_recieved.connect(_add_crewmate_to_system.bind(zone));
		zone.card_lost.connect(_remove_crewmate_from_system);
