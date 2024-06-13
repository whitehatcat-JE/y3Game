extends Node3D

func _ready():
	Music.playSong("city")
	FM.playerData.changeLocation("city")
