extends Node3D

func _ready():
	Music.playSong("city")
	FM.playerData.changeLocation("city")
	
	if FM.playerData.hasFishingRod:
		%fishermanInteractable.hasIntroduced = true

	GS.event.connect(eventTriggered)

func eventTriggered(identifier:String, value):
	if identifier == "giveFishingRod":
		FM.playerData.hasFishingRod = true
		FM.saveGame()
		GS.emit_signal("eventFinished")
