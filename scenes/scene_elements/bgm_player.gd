extends Node


const sound_id_per_layer : Dictionary[MapState.HyperspaceDepth, SoundLoader.SoundID] = {
	MapState.HyperspaceDepth.NONE: SoundLoader.SoundID.PH1,
	MapState.HyperspaceDepth.SHALLOW: SoundLoader.SoundID.PH2,
	MapState.HyperspaceDepth.NORMAL: SoundLoader.SoundID.PH3,
	MapState.HyperspaceDepth.DEEP: SoundLoader.SoundID.PH4,
	MapState.HyperspaceDepth.DELTA: SoundLoader.SoundID.PH1,
};

const TRANSITION_TIME : float = 2.0;


var current_track : SoundLoader.SoundID = -1;
var play_from : float = 0.0;

var last_player : AudioStreamPlayer;
var player_tweens : Dictionary[AudioStreamPlayer, Tween];


func add_player() -> AudioStreamPlayer:
	var new_player = AudioStreamPlayer.new();
	new_player.bus = &"Music";
	
	player_tweens[new_player] = null;
	add_child(new_player);
	
	return new_player;


func remove_player(player: AudioStreamPlayer) -> void:
	if player_tweens[player]:
		player_tweens[player].kill();
	
	player_tweens.erase(player);
	remove_child(player);


func change_layer_track(_dummy_arg = null) -> void:
	if GameState.map == null:
		return;
	
	var new_track = sound_id_per_layer[GameState.map.layer];
	
	if new_track == current_track:
		return;
	current_track = new_track;
	
	if last_player != null:
		if player_tweens[last_player]:
			player_tweens[last_player].kill();
		var lp_tween = create_tween();
		player_tweens[last_player] = lp_tween;
		
		play_from = last_player.get_playback_position();
		
		lp_tween.tween_property(last_player, ^"volume_linear", 0.0, TRANSITION_TIME);
		lp_tween.tween_callback(remove_player.bind(last_player));
	
	var new_player = add_player();
	last_player = new_player;
	
	var stream := SoundLoader.get_stream_by_id(new_track);
	match stream: # set up looping
		_ when stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LoopMode.LOOP_FORWARD;
			stream.loop_end = stream.get_length() * stream.mix_rate;
		_ when stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
			stream.loop = true;
		_:
			# other cases not implemented
			push_warning("unexpected music stream type, looping won't work");
	new_player.stream = stream;
	
	new_player.volume_linear = 0.0;
	var np_tween = create_tween();
	player_tweens[new_player] = np_tween;
	np_tween.tween_property(new_player, ^"volume_linear", 1.0, TRANSITION_TIME);
	
	new_player.play(play_from);


func _ready() -> void:
	GameState.new_map.connect(change_layer_track);
	GameState.new_phase.connect(change_layer_track);
