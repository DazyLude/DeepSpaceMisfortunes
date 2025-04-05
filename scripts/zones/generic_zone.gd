extends Area2D
class_name GenericTableZone


var card_destination_position := Vector2();

@export var stack_limit : int = 1;
@export var accepts_stacks : bool = false;


func _can_accept_card(_card: GenericCard, _table: Table) -> bool:
	push_warning("Generic function _can_accept_card is not overloaded"); 
	return true;


func _card_accepted(_card: GenericCard, _table: Table):
	pass;


func _card_removed(_card: GenericCard, _table: Table):
	pass;
