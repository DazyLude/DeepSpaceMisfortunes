extends Node2D
class_name Table

var active_cards : Dictionary[GenericCard, RefCounted] = {};
var picked_card_ref : GenericCard = null;
var grabbed_offset := Vector2();


func add_active_card(card: GenericCard) -> void:
	active_cards[card] = null;
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


func dropped_card(card: GenericCard) -> void:
	picked_card_ref = null;


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and picked_card_ref != null:
		picked_card_ref.position = event.position + grabbed_offset;


func _ready() -> void:
	add_active_card($GenericCard);
	add_active_card($GenericCard2);
	add_active_card($GenericCard3);
