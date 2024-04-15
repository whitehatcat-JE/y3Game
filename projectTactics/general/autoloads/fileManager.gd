extends Node

var saveFilePath : String = "user://saves/"

var saveID : String = "0" #str(OS.get_datetime()).sha256_text()

var playerData : PlayerData = PlayerData.new()

func _ready():
	DirAccess.make_dir_absolute(saveFilePath)

func saveGlobal():
	pass

func loadGlobal():
	pass

func saveGame():
	ResourceSaver.save(playerData, saveFilePath + saveID + ".tres")

func loadGame():
	var newPlayerData : PlayerData = PlayerData.new()
	
	if ResourceLoader.exists(saveFilePath + saveID + ".tres"):
		newPlayerData  = ResourceLoader.load(saveFilePath + saveID + ".tres").duplicate(true)
	playerData.constructor(newPlayerData)
