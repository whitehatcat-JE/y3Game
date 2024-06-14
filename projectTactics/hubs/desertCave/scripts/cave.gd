extends Node3D

var playerInfo:PlayerData

@export var wornUnit:Unit
@export var requiredItems:Array[Part] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	playerInfo = $player.playerInfo
	GS.event.connect(eventTriggered)
	Music.playSong("cave")
	
	FM.playerData.changeLocation("cave")
	FM.audioUpdated.connect(updateSFX)
	updateSFX()

func eventTriggered(identifier:String, value):
	if identifier == "caveDwellerAssemble":
		var smallestItemCount:int = 1000000
		for item in requiredItems:
			if item not in playerInfo.inventory.keys():
				GS.emit_signal("triggerDialogue", "caveDwellerFail")
				return
			smallestItemCount = min(smallestItemCount, playerInfo.inventory[item])
		for item in requiredItems:
			playerInfo.removeFromInventory(item, smallestItemCount)
		playerInfo.addToInventory(wornUnit, smallestItemCount)
		if smallestItemCount == 1:
			$player/UI/dialogueMenu.startCustomDialogue(
				["Perfect! Now just give me a moment...",
				"And hey presto!",
				"1x Well Worn Mech Acquired!"]
			)
		else:
			$player/UI/dialogueMenu.startCustomDialogue(
				["Perfect! Now just give me a moment...",
				"And hey presto!",
				str(smallestItemCount) + "x Well Worn Mechs Acquired!"]
			)

func updateSFX():
	%waterAmbienceSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 30
	%waterfallSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 20
