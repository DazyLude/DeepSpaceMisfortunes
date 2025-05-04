extends FlyEvent


func _init() -> void:
	is_consumed = EventPool.EventLimitType.LIMITED;
