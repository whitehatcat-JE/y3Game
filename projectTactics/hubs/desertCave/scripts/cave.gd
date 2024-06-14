extends Node3D

var playerInfo:PlayerData

@export var wornUnit:Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	playerInfo = $player.playerInfo
	GS.event.connect(eventTriggered)
	Music.playSong("cave")
	
	FM.playerData.changeLocation("cave")
	FM.audioUpdated.connect(updateSFX)
	updateSFX()

func eventTriggered(identifier:String, value):
	if identifier == "caveAssembleUnit":
		playerInfo.addToInventory(wornUnit)
		GS.emit_signal("triggerDialogue", "caveAssembleUnitComplete")
		return
		for item in playerInfo.inventory:
			if item.name == "Worn Iron Arm":
				playerInfo.removeFromInventory(item, 1)
				playerInfo.addToInventory(wornUnit)
				GS.emit_signal("triggerDialogue", "caveAssembleUnitComplete")
				return
		GS.emit_signal("triggerDialogue", "caveAssembleUnitFail")

func updateSFX():
	%waterAmbienceSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 30
	%waterfallSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 20
