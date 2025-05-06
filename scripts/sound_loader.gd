extends RefCounted
class_name SoundLoader


enum SoundID {
	PH1,
	PH2,
	PH3,
	PH4,
	
	ALERT,
	ALERT_BAD,
	BLING,
	SLOT_IN,
}


const uid_per_sound_id : Dictionary[SoundID, String] = {
	SoundID.PH1: "uid://bcqvh8ysoioc2",
	SoundID.PH2: "uid://c57175uw7ncv0",
	SoundID.PH3: "uid://dxv0ml1ywf367",
	SoundID.PH4: "uid://o46vg5hvke1t",
	
	SoundID.ALERT: "uid://d0kgab5coxsgg",
	SoundID.ALERT_BAD: "uid://b41ooxapmiuxp",
	SoundID.BLING: "uid://dy1vp78o8fgfv",
	SoundID.SLOT_IN: "uid://dw6q0njiojoou",
}


static func get_stream_by_id(id: SoundID) -> AudioStream:
	var uid = uid_per_sound_id[id];
	return ResourceLoader.load(uid);
