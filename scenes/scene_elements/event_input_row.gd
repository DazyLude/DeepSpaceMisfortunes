extends Control
class_name EventInputRow


func get_label() -> Label:
	return $Label;


func get_zone() -> EventZone:
	return $InputZoneContainer/EventZone;


func get_sprite() -> Sprite2D:
	return $InputZoneContainer/EventZone/CardSlotImage;
