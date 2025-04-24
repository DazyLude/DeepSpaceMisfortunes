extends GenericTableZone
class_name EventZone


signal card_recieved(GenericCard);
signal card_lost(GenericCard);



@export var accepted_card_types : Array[GameState.TokenType] = [];


func _can_accept_card(card: GenericCard, table: Table) -> bool:
	var token_type := table.get_card_token_type(card);
	return accepted_card_types.has(token_type);


func _card_accepted(_card: GenericCard, _table: Table):
	card_recieved.emit(_card);


func _card_removed(_card: GenericCard, _table: Table):
	card_lost.emit(_card);
