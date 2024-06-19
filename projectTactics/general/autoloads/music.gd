extends Node
# Volume threshold before cutting volume off
const MIN_VOLUME:float = -20.0
# Audio playing variables
var currentTrack:AudioStreamPlayer = null

var fadeOutTween:Tween = null
var fadeInTween:Tween = null
# Current volume
var volume:float = 0.0
# Plays requested song
func playSong(songName:String):
	# Checks that song exists
	var songTrack:AudioStreamPlayer = get_node_or_null(songName)
	if songTrack == currentTrack: return;
	# Ends previous song fade in/out event if not finished
	if fadeOutTween != null:
		fadeOutTween.custom_step(1.0)
	if fadeInTween != null:
		fadeInTween.custom_step(1.0)
	# Fades out current song
	if currentTrack != null:
		fadeOutTween = get_tree().create_tween().set_ease(
			Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		fadeOutTween.tween_property(currentTrack, "volume_db", -80.0, 1.0)
		fadeOutTween.tween_property(currentTrack, "playing", false, 0)
	# Fades in new song
	if songTrack != null:
		songTrack.playing = true
		songTrack.volume_db = -80.0
		fadeInTween = get_tree().create_tween().set_ease(
			Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		fadeInTween.tween_property(songTrack, "volume_db", volume, 1.0)
	# Caches new song
	currentTrack = songTrack
# Updates volume of current song
func changeVolume(newVolume:float):
	if newVolume <= MIN_VOLUME: newVolume = -80;
	volume = newVolume
	# Force updates volume if song currently fading in/out
	if fadeOutTween != null: fadeOutTween.custom_step(1.0);
	if fadeInTween != null: fadeInTween.custom_step(1.0);
	if currentTrack != null: currentTrack.volume_db = volume;
