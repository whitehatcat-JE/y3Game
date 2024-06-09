extends Node

var currentTrack:AudioStreamPlayer = null

var transitionDelay:SceneTreeTimer = null

func playSong(songName:String):
	var songTrack:AudioStreamPlayer = get_node_or_null(songName)
	
	if songTrack == currentTrack: return;
	if currentTrack != null:
		var fadeOutTween:Tween = get_tree().create_tween().set_ease(
			Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		fadeOutTween.tween_property(currentTrack, "volume_db", -80.0, 1.0)
		fadeOutTween.tween_property(currentTrack, "playing", false, 0)
	if songTrack != null:
		songTrack.playing = true
		songTrack.volume_db = -80.0
		var fadeInTween:Tween = get_tree().create_tween().set_ease(
			Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		fadeInTween.tween_property(songTrack, "volume_db", 0.0, 1.0)
	currentTrack = songTrack
