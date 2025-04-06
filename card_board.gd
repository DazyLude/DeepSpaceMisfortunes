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
var token_stacks : Array[TokenStack] = [];

var current_event : GenericEvent = null;

var picked_card_ref : GenericCard = null;
var grabbed_offset := Vector2();


func get_card_token_type(card: GenericCard) -> TokenType:
	match active_cards.get(card, null):
		var crew when crew is GameState.Crewmate:
			return TokenType.CREWMATE;
		var other_token when other_token is GameState.OtherToken:
			return other_token.token_type; 
		_:
			return TokenType.OTHER;


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
	card.picked.connect(picked_card.bind(card));
	card.dropped.connect(dropped_card.bind(card));


func remove_active_card(card: GenericCard) -> void:
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
				
				var another_card when is_same_type and not zone.accepts_stacks:
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


func spawn_token(token_type: TokenType, token_data: RefCounted = null) -> void:
	var token : GenericCard;
	var ph_token_data : RefCounted;
	var where : Vector2;
	
	match token_type:
		TokenType.CREWMATE:
			token = load("res://cards/tokens/crewmate.tscn").instantiate();
			ph_token_data = GameState.Crewmate.new();
			where = Vector2(100, 400);
		TokenType.INGOT:
			token = load("res://cards/tokens/contraband.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_ingot_token();
			where = Vector2(200, 400);
		TokenType.SHIP_NAVIGATION:
			token = load("res://cards/tokens/ship_navigation.tscn").instantiate();
			ph_token_data = GameState.OtherToken.get_nav_token();
			where = Vector2(300, 400);
	
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
		token.queue_free();
		remove_active_card(token);
	
	for stack in $Stacks.get_children():
		$Stacks.remove_child(stack);
		stack.queue_free();
		remove_stack(stack);
	
	for zone in active_zones:
		active_zones[zone] = null;


func spawn_event(event_instance: GenericEvent) -> void:
	despawn_event();
	if event_instance == null:
		return;
	
	$Events.add_child(event_instance);
	
	for zone in event_instance.event_zones:
		add_active_zone(zone);
	
	event_instance.position = Vector2(980, 360);
	
	current_event = event_instance;


func despawn_event() -> void:
	if current_event != null:
		current_event._action();
		
		for zone in current_event.event_zones:
			remove_active_zone(zone);
		
		$Events.remove_child(current_event);
		current_event = null;


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and picked_card_ref != null:
		picked_card_ref.position = event.position + grabbed_offset;


func _ready() -> void:
	GameState.new_game(self);
	
	var ship : Ship = $Ship;
	for zone in ship.get_active_zones():
		add_active_zone(zone);
	
	$Button.pressed.connect(GameState.advance_phase);
	
	GameState.new_event.connect(spawn_event);
	GameState.new_token.connect(spawn_token);
	GameState.clear_tokens.connect(despawn_all_tokens);
