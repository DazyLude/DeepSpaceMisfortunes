extends Node2D
class_name Table


const nav_token_spawn_location := Vector2(910.0, 665.0);
const crew_token_spawn_location := Vector2(375.0, 560.0);
const ingot_token_spawn_location := Vector2(375.0, 230.0);

const EVENT_POSITION := Vector2(1200, 400);
const STATION_POSITION := Vector2(250, 50);

var active_cards : Dictionary[GenericCard, RefCounted] = {};
var active_zones : Dictionary[GenericTableZone, GenericCard] = {};
var token_stacks : Array[TokenStack] = [];

var current_event : GenericEvent = null;
var ship : Ship = null;

var picked_card_ref : GenericCard = null;
var grabbed_offset := Vector2();

var grace : bool = false;
var GRACE_PERIOD : float = 0.3;


func get_card_token_type(card: GenericCard) -> GameState.TokenType:
	match active_cards.get(card, null):
		var crew when crew is ShipState.Crewmate:
			return GameState.TokenType.CREWMATE;
		var other_token when other_token is GameState.OtherToken:
			return other_token.token_type; 
		_:
			return GameState.TokenType.OTHER;


func zone_collision_check(card: GenericCard, zone: GenericTableZone) -> bool:
	return card.hitbox.overlaps_area(zone) and card.visible and zone.visible;


func card_collision_check(card: GenericCard, another: GenericCard) -> bool:
	return card.hitbox.overlaps_area(another.hitbox) and card.visible and another.visible;


func add_active_zone(zone: GenericTableZone) -> void:
	assert(zone != null, "trying to add a null zone to the board");
	
	active_zones[zone] = null;


func remove_active_zone(zone: GenericTableZone) -> void:
	active_zones.erase(zone);


func add_active_card(card: GenericCard, card_data: RefCounted = null) -> void:
	active_cards[card] = card_data;
	card.owner_table = self;
	card.picked.connect(picked_card.bind(card));
	card.dropped.connect(dropped_card.bind(card));


func remove_active_card(card: GenericCard) -> void:
	card.owner_table = null;
	active_cards.erase(card);


func spawn_stack(stack: TokenStack, zone: GenericTableZone = null) -> void:
	$Stacks.add_child(stack);
	stack.picked.connect(stack.card_removed.bind(null, self));
	if zone != null:
		stack.picked_from_stack.connect(zone._card_removed.bind(self));
	token_stacks.push_back(stack);


func remove_stack(stack: TokenStack) -> void:
	var stack_zone_owner = active_zones.find_key(stack);
	if stack_zone_owner != null:
		active_zones[stack_zone_owner] = stack.tokens.back();
	
	$Stacks.remove_child(stack);
	token_stacks.erase(stack);


func picked_card(card: GenericCard) -> void:
	if picked_card_ref != null:
		dropped_card(card);
	
	if card != null:
		grabbed_offset = card.position - get_local_mouse_position();
		grabbed_offset = grabbed_offset.clamp(card.hitbox_shape.shape.size * -0.3, card.hitbox_shape.shape.size * 0.3)
		picked_card_ref = card;
		
		card.fly_with_shadow();
		
		var card_owner_zone := active_zones.find_key(card) as GenericTableZone;
		if card_owner_zone != null:
			active_zones[card_owner_zone] = null;
			card_owner_zone._card_removed(card, self);


func dropped_card(card: GenericCard) -> void:
	card.stop_flying();
	
	for zone in active_zones:
		if zone_collision_check(card, zone) and zone._can_accept_card(card, self):
			var zone_content := active_zones[zone];
			
			if zone_content == card:
				picked_card_ref = null;
				return;
			
			var is_same_type := zone_content is GenericCard \
				and get_card_token_type(card) == get_card_token_type(zone_content);
			
			var is_valid_stack : bool = zone_content is TokenStack \
				and token_stacks.has(zone_content) \
				and get_card_token_type(card) == zone_content.get_token_type(self)
			
			match active_zones[zone]:
				null:
					zone._card_accepted(card, self);
					card.position = self.to_local(zone.to_global(zone.card_destination_position));
					active_zones[zone] = card;
				
				var another_card when is_same_type and zone.accepts_stacks:
					var new_stack = TokenStack.from_two_tokens(card, another_card);
					new_stack.position = another_card.position;
					active_zones[zone] = new_stack;
					spawn_stack(new_stack, zone);
					if zone is EventZone:
						zone._card_accepted(card, self);
				
				var _another_card when is_same_type and not zone.accepts_stacks:
					picked_card_ref = null;
					return;
				
				var stack when is_valid_stack and zone.stack_limit > stack.tokens.size():
					stack.card_added(card, self);
				
				var stack when is_valid_stack and zone.stack_limit <= stack.tokens.size():
					picked_card_ref = null;
					return;
				_:
					push_error("unexpected collision scenario");
					break;
			
			picked_card_ref = null;
			return;
	
	for stack in token_stacks:
		if card_collision_check(card, stack) \
			and get_card_token_type(card) == stack.get_token_type(self):
				stack.card_added(card, self);
				picked_card_ref = null;
				return;
	
	for another_card in active_cards:
		if card != another_card \
			and card_collision_check(card, another_card) \
			and active_zones.find_key(another_card) == null \
			and get_card_token_type(card) == get_card_token_type(another_card):
				var new_stack = TokenStack.from_two_tokens(card, another_card);
				new_stack.position = card.position;
				spawn_stack(new_stack);
				picked_card_ref = null;
				return;
	
	picked_card_ref = null;


func spawn_token(token_type: GameState.TokenType, token_data: RefCounted = null) -> void:
	var token : GenericCard;
	var ph_token_data : RefCounted;
	var where : Vector2;
	
	match token_type:
		GameState.TokenType.CREWMATE:
			token = load("res://cards/tokens/crewmate.tscn").instantiate();
			ph_token_data = ShipState.Crewmate.new();
			where = crew_token_spawn_location;
		GameState.TokenType.INGOT:
			token = load("res://cards/tokens/contraband.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_ingot_token();
			where = ingot_token_spawn_location;
		GameState.TokenType.SHIP_NAVIGATION:
			token = load("res://cards/tokens/ship_navigation.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_nav_token();
			where = nav_token_spawn_location;
	
	token.position = where;
	$Tokens.add_child(token);
	add_active_card(token, token_data if token_data != null else ph_token_data);
	
	var respective_stack_i = token_stacks.find_custom(
		func(t: TokenStack): return t.get_token_type(self) == token_type and active_zones.find_key(t) == null;
	);
	if respective_stack_i != -1:
		token_stacks[respective_stack_i].card_added(token, self);
		return;
	
	var other_tokens = active_cards.keys();
	var similar_card_i = other_tokens.find_custom(
		func(t: GenericCard): return get_card_token_type(t) == token_type and t != token;
	);
	if similar_card_i != -1:
		var other_token = other_tokens[similar_card_i];
		var new_stack = TokenStack.from_two_tokens(token, other_token);
		new_stack.position = token.position;
		spawn_stack(new_stack);
		return;


func despawn_all_tokens() -> void:
	for token in $Tokens.get_children():
		$Tokens.remove_child(token);
		remove_active_card(token);
		token.queue_free();
	
	for stack in $Stacks.get_children():
		remove_stack(stack);
		stack.queue_free();
	
	for zone in active_zones:
		active_zones[zone] = null;


func shake_tokens(token_type: GameState.TokenType) -> void:
	for card in self.active_cards.keys():
		if (get_card_token_type(card) == token_type):
			card.shake();
	
	for stack in self.token_stacks:
		if stack.get_token_type(self) == token_type:
			stack.shake();


func spawn_event(event_instance: GenericEvent) -> void:
	despawn_event();
	
	if event_instance == null:
		return;
	
	event_instance._prepare();
	
	$Events.add_child(event_instance);
	
	if event_instance is FlyEvent:
		event_instance.position = EVENT_POSITION;
		
		for zone in event_instance.get_event_zones():
			add_active_zone(zone);
		
		prepare_fly_event();
	
	if event_instance is StationEvent:
		event_instance.position = STATION_POSITION;
		
		prepare_station();
	
	current_event = event_instance;


func despawn_event() -> void:
	if current_event != null:
		current_event._action();
		
		if current_event is FlyEvent:
			for zone in current_event.get_event_zones():
				remove_active_zone(zone);
		
		$Events.remove_child(current_event);
		current_event.queue_free();
		current_event = null;


func spawn_ship(ship_state: ShipState) -> void:
	despawn_ship()
	
	if ship_state == null:
		return;
	
	ship = ship_state.renderer_scene.instantiate();
	
	if ship != null:
		ship.position = Vector2(420.0, 400.0);
		$Ship.add_child(ship);
		for zone in ship.get_active_zones():
			add_active_zone(zone);


func despawn_ship() -> void:
	if ship != null:
		$Ship.remove_child(ship);
		ship.queue_free();


func prepare_station() -> void:
	$ProgressBar.hide();
	$Button.hide();
	$Ship.hide();
	$Tokens.hide();
	$Stacks.hide();


func prepare_fly_event() -> void:
	$ProgressBar.show();
	$Button.show();
	$Ship.show();
	$Tokens.show();
	$Stacks.show();


func try_to_advance_phase() -> void:
	if not grace:
		GameState.advance_phase();
		grace = true;
		await get_tree().create_timer(GRACE_PERIOD).timeout;
		grace = false;


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and picked_card_ref != null:
		picked_card_ref.position = event.position + grabbed_offset;


func _ready() -> void:
	GameState.go_to_menu();
	
	$Button.pressed.connect(try_to_advance_phase);
	
	GameState.new_event.connect(spawn_event);
	GameState.new_ship.connect(spawn_ship);
	GameState.new_token.connect(spawn_token);
	
	GameState.clear_tokens.connect(despawn_all_tokens);
	GameState.ping_tokens.connect(shake_tokens, CONNECT_DEFERRED);
