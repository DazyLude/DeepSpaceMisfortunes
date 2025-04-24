extends GenericCard
class_name TokenStack


signal picked_from_stack(GenericCard);


var tokens : Array[GenericCard] = [];
var label : Label = null;


func get_token_type(table: Table) -> GameState.TokenType:
	return table.get_card_token_type(tokens[0]);


func card_added(card: GenericCard, table: Table):
	if tokens.has(card):
		return;
	
	var stack_owner_zone = table.active_zones.find_key(self) as EventZone;
	if stack_owner_zone != null:
		stack_owner_zone._card_accepted(card, table);
	
	tokens.push_back(card);
	card.hide();
	
	label.text = "%d" % tokens.size();


func card_removed(_card: GenericCard, table: Table):
	var card = tokens.pop_back();
	
	card.position = position;
	
	picked_from_stack.emit(card);
	card.show();
	table.picked_card(card);
	
	label.text = "%d" % tokens.size();
	
	if tokens.size() == 1:
		var last_token = tokens.back();
		last_token.position = position;
		
		last_token.show();
		table.remove_stack.call_deferred(self);
		self.hide();


static func from_two_tokens(token : GenericCard, another : GenericCard) -> TokenStack:
	var stack := load("res://cards/generic_card.tscn").instantiate() as GenericCard;
	stack.set_script(TokenStack);
	stack.can_have_shadow = false;
	
	stack.tokens.push_back(token);
	stack.tokens.push_back(another);
	
	var corcle = Sprite2D.new();
	corcle.texture = preload("res://assets/graphics/circle.png");
	corcle.position = Vector2(30, 40);
	stack.add_child(corcle);
	
	stack.card_texture = token.sprite.texture.duplicate();
	var label := Label.new();
	
	label.position = Vector2(21, 28);
	label.size = Vector2(20, 30);
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	label.text = "2";
	
	stack.label = label;
	stack.add_child(label);
	
	token.hide();
	another.hide();
	
	return stack;
