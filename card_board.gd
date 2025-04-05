extends Node2D
class_name Table


enum TokenType {
	CREWMATE,
	INGOT,
	SHIP_NAVIGATION,
	OTHER,
}


var active_cards : Dictionary[GenericCard, RefCounted] = {};
var active_zones : Dictionary[GenericTableZone, GenericCard] = {};

var picked_card_ref : GenericCard = null;
var grabbed_offset := Vector2();


func get_card_token_type(card: GenericCard) -> TokenType:
	match active_cards.get(card, null):
		var crew when crew is GameState.Crewmate:
			return TokenType.CREWMATE;
		_:
			return TokenType.OTHER;


func collision_check(card: GenericCard, zone: GenericTableZone) -> bool:
	return card.hitbox.overlaps_area(zone);


func add_active_zone(zone: GenericTableZone) -> void:
	assert(zone != null, "trying to add a null zone to the board");
	
	active_zones[zone] = null;


func remove_active_zone(zone: GenericTableZone) -> void:
	active_zones.erase(zone);


func add_active_card(card: GenericCard, card_data: RefCounted = null) -> void:
	active_cards[card] = card_data;
	card.picked.connect(picked_card.bind(card));
	card.dropped.connect(dropped_card.bind(card));


func remove_active_card(card: GenericCard) -> void:
	active_cards.erase(card);


func picked_card(card: GenericCard) -> void:
	if picked_card_ref != null:
		dropped_card(card);
	
	if card != null:
		grabbed_offset = card.position - get_local_mouse_position();
		picked_card_ref = card;
		
		var card_owner_zone := active_zones.find_key(card) as GenericTableZone;
		if card_owner_zone != null:
			active_zones[card_owner_zone] = null;
			card_owner_zone._card_removed();


func dropped_card(card: GenericCard) -> void:
	for zone in active_zones:
		if collision_check(card, zone) and zone._can_accept_card(card, self):
			zone._card_accepted();
			card.position = self.to_local(zone.to_global(zone.card_destination_position));
			active_zones[zone] = card;
	
	picked_card_ref = null;


func spawn_token(token_type: TokenType, where: Vector2, token_data: RefCounted = null) -> void:
	var token : GenericCard;
	var ph_token_data : RefCounted;
	
	match token_type:
		TokenType.CREWMATE:
			token = load("res://cards/tokens/crewmate.tscn").instantiate();
			ph_token_data = GameState.Crewmate.new()
		TokenType.INGOT:
			token = load("res://cards/tokens/contraband.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_ingot_token();
		TokenType.SHIP_NAVIGATION:
			token = load("res://cards/tokens/ship_navigation.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_nav_token();
	
	token.position = where;
	add_child(token);
	add_active_card(token, token_data if token_data != null else ph_token_data);


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and picked_card_ref != null:
		picked_card_ref.position = event.position + grabbed_offset;


func _ready() -> void:
	GameState.new_game();
	
	spawn_token(TokenType.CREWMATE, Vector2(100, 100));
	spawn_token(TokenType.INGOT, Vector2(100, 150));
	spawn_token(TokenType.SHIP_NAVIGATION, Vector2(100, 200));
	
	var ship : Ship = $Ship;
	for zone in ship.get_active_zones():
		add_active_zone(zone);
	
	$Button.pressed.connect(GameState.advance_phase);
