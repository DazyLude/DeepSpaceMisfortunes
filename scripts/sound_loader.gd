extends RefCounted
class_name SoundLoader


enum SoundID {
	PH1,
	PH2,
	
	ALERT,
	ALERT_BAD,
	BLING,
	SLOT_IN,
}


const uid_per_sound_id : Dictionary[SoundID, String] = {
	SoundID.PH1: "uid://dbdpgeh8nyrhc",
	SoundID.PH2: "uid://c2k2gl1ak8lv6",
	
	SoundID.ALERT: "uid://d0kgab5coxsgg",
	SoundID.ALERT_BAD: "uid://b41ooxapmiuxp",
	SoundID.BLING: "uid://dy1vp78o8fgfv",
	SoundID.SLOT_IN: "uid://dw6q0njiojoou",
}


static func get_stream_by_id(id: SoundID) -> AudioStream:
	var uid = uid_per_sound_id[id];
	return ResourceLoader.load(uid);
