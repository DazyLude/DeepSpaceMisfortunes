extends GenericCard
class_name TokenStack


signal picked_from_stack(GenericCard);


var tokens : Array[GenericCard] = [];
var label : Label = null;


func get_token_type(table: Table) -> Table.TokenType:
	return table.get_card_token_type(tokens[0]);


func card_added(card: GenericCard, _table: Table):
	if tokens.has(card):
		return;
	
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
	
	stack.card_texture = token.sprite.texture.duplicate();
	stack.label = Label.new();
	stack.label.text = "2";
	stack.add_child(stack.label);
	
	token.hide();
	another.hide();
	
	return stack;
