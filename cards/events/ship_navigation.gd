extends GenericEvent


var course : int;


func course_chosen(_card, which: int) -> void:
	course = which;


func course_unchosen(_card) -> void:
	course = -1;


func _can_play() -> bool:
	return course != -1;


func _action() -> void:
	GameState.hyper_depth += course - 1;
	GameState.hyper_depth = clampi(GameState.hyper_depth, 0, 3);


func _init() -> void:
	event_zone_types.clear();
	
	event_zone_labels[0] = "ascend";
	event_zone_labels[1] = "stay on this level";
	event_zone_labels[2] = "descend";
	
	event_zone_types.push_back(Table.TokenType.SHIP_NAVIGATION);
	event_zone_types.push_back(Table.TokenType.SHIP_NAVIGATION);
	event_zone_types.push_back(Table.TokenType.SHIP_NAVIGATION);


func _ready() -> void:
	super._ready();
	
	event_zones[0].card_recieved.connect(course_chosen.bind(0));
	event_zones[0].card_lost.connect(course_unchosen);
	
	event_zones[1].card_recieved.connect(course_chosen.bind(1));
	event_zones[1].card_lost.connect(course_unchosen);
	
	event_zones[2].card_recieved.connect(course_chosen.bind(2));
	event_zones[2].card_lost.connect(course_unchosen);
