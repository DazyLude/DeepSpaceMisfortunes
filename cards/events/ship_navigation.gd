extends GenericEvent


var course : int;


func course_chosen(which: int) -> void:
	course = which;


func course_unchosen() -> void:
	course = -1;


func _can_play() -> bool:
	return course != -1;


func _action() -> void:
	GameState.hyper_depth += course - 1;
	GameState.hyper_depth = clampi(GameState.hyper_depth, 0, 3);


func _ready() -> void:
	$AscendInput.card_recieved.connect(course_chosen.bind(0));
	$StayInput.card_recieved.connect(course_chosen.bind(1));
	$DescendInput.card_recieved.connect(course_chosen.bind(2));
	
	$AscendInput.card_lost.connect(course_unchosen);
	$StayInput.card_lost.connect(course_unchosen);
	$DescendInput.card_lost.connect(course_unchosen);
