extends Node3D

# Workshop scene initialization
func _ready():
	FM.playerData.changeLocation("workshop")
	Music.playSong("city")
