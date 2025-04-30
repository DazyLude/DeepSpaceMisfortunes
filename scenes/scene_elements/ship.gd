extends Node2D
class_name Ship;


@onready
var zone_to_system_slot : Dictionary[GenericTableZone, int] = {
	$OuterHullSlot: 0,
	$HyperSlot: 1,
	$EnginesSlot: 2,
	$AutopilotSlot: 3,
	$InnerHullSlot: 4,
	$NavigationSlot: 5,
	$LifeSupportSlot: 6,
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
var hp_per_system_slot : Dictionary[int, Node] = {
	0: $OuterHullSlot/HP,
	1: $HyperSlot/HP, 
	2: $EnginesSlot/HP,
	3: $AutopilotSlot/HP,
	4: $InnerHullSlot/HP, 
	5: $NavigationSlot/HP,
	6: $LifeSupportSlot/HP,
}


const flare_time : float = 1.5;
var green_gradient = GradientTexture1D.new();
var red_gradient = GradientTexture1D.new();


func update_hp_display(_s) -> void:
	for system_slot in hp_per_system_slot:
		hp_per_system_slot[system_slot].text = "%d" % GameState.ship.get_system_by_slot(system_slot).hp;


func get_active_zones() -> Array[GenericTableZone]:
	var zones : Array[GenericTableZone] = [];
	for c in self.get_children().filter(func(x): return x is EventZone):
		zones.push_back(c);

	return zones;


func hide_manned_icons() -> void:
	for system_slot in zone_to_system_slot:
		var manned_icon := system_slot.get_node("Manned");
		manned_icon.hide();


func update_manned_icons() -> void:
	for system_slot in zone_to_system_slot:
		var manned_icon := system_slot.get_node("Manned");
		var system := zone_to_system_slot[system_slot];
		
		manned_icon.visible = GameState.ship.is_system_slot_manned(system);


func on_system_damaged(system_slot: int) -> void:
	var system_node = zone_to_system_slot.find_key(system_slot);
	if system_node != null:
		var system_icon = system_node.get_node("Background");
		flare_red(system_icon);


func on_system_repaired(system_slot: int) -> void:
	var system_node = zone_to_system_slot.find_key(system_slot);
	if system_node != null:
		var system_icon = system_node.get_node("Background");
		flare_green(system_icon);


func update_warning_icon(_p) -> void:
	$Warning.visible = GameState.life_support_failure;


func _add_crewmate_to_system(card: GenericCard, zone: GenericTableZone) -> void:
	var table_ref = card.owner_table;
	if table_ref != null:
		GameState.ship.man_system(table_ref.active_cards[card], zone_to_system_slot[zone]);


func _remove_crewmate_from_system(card: GenericCard) -> void:
	var table_ref = card.owner_table;
	if table_ref != null:
		GameState.ship.stop_manning(table_ref.active_cards[card]);


func flare_red(icon: Sprite2D) -> void:
	icon.material.set_shader_parameter(&"color", red_gradient);
	icon.material.set_shader_parameter(&"intensity", 0.2);
	icon.material.set_shader_parameter(&"thickness", 1.0);
	
	if icon_tweens.get(icon, null):
		icon_tweens[icon].kill();
	
	var tween := create_tween();
	
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 1.0, flare_time)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT);
	tween.parallel().tween_property(icon, ^"material:shader_parameter/thickness", 3.5, flare_time);
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 0.2, flare_time)\
		.set_ease(Tween.EASE_IN);
	tween.parallel().tween_property(icon, ^"material:shader_parameter/thickness", 1.0, flare_time);
	
	icon_tweens[icon] = tween;


func flare_green(icon: Sprite2D) -> void:
	icon.material.set_shader_parameter(&"color", green_gradient);
	icon.material.set_shader_parameter(&"intensity", 0.2);
	icon.material.set_shader_parameter(&"thickness", 1.0);
	
	if icon_tweens.get(icon, null):
		icon_tweens[icon].kill();
	
	var tween := create_tween();
	
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 1.0, flare_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	tween.parallel().tween_property(icon, ^"material:shader_parameter/thickness", 3.5, flare_time);
	tween.tween_property(icon, ^"material:shader_parameter/intensity", 0.2, flare_time)\
		.set_ease(Tween.EASE_IN);
	tween.parallel().tween_property(icon, ^"material:shader_parameter/thickness", 1.0, flare_time);
	
	icon_tweens[icon] = tween;


func set_icon_materials() -> void:
	for system_slot in zone_to_system_slot:
		var icon := system_slot.get_node("Background");
		setup_icon_outline_shader(icon);


func setup_icon_outline_shader(icon: Sprite2D) -> void:
	var shader := preload("res://shaders/outline.gdshader");
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader;
	
	shader_material.set_shader_parameter(&"color", green_gradient);
	shader_material.set_shader_parameter(&"gradientResolution", 30);
	shader_material.set_shader_parameter(&"thickness", 1.0);
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
