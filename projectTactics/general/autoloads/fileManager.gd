extends Node

var saveFilePath : String = "user://saves/"
var saveListFilePath : String = "user://saves/saveList.tres"

var loadedGlobalData : GlobalData

var activeSaveID : String = "0"

var playerData : PlayerData = PlayerData.new()

func _ready():
	DirAccess.make_dir_absolute(saveFilePath)
	if ResourceLoader.exists(saveListFilePath):
		loadedGlobalData = ResourceLoader.load(saveListFilePath).duplicate(true)
	else:
		loadedGlobalData = GlobalData.new()
		ResourceSaver.save(loadedGlobalData, saveListFilePath)

func saveGlobal():
	ResourceSaver.save(loadedGlobalData, saveListFilePath)

func loadGlobal():
	if ResourceLoader.exists(saveListFilePath):
		loadedGlobalData = ResourceLoader.load(saveListFilePath).duplicate(true)
	else:
		loadedGlobalData = GlobalData.new()
		ResourceSaver.save(loadedGlobalData, saveListFilePath)

func createGame():
	activeSaveID = str(Time.get_unix_time_from_system()).sha256_text()
	loadedGlobalData.saveIDs.append(activeSaveID)
	saveGlobal()
	loadAndEnterGame(activeSaveID)

func saveGame():
	ResourceSaver.save(playerData, saveFilePath + activeSaveID + ".tres")

func loadGame():
	var newPlayerData : PlayerData
	if ResourceLoader.exists(saveFilePath + activeSaveID + ".tres"):
		newPlayerData  = ResourceLoader.load(saveFilePath + activeSaveID + ".tres").duplicate(true)
	else:
		newPlayerData = PlayerData.new()
	playerData.constructor(newPlayerData)

func loadAndEnterGame(saveID):
	activeSaveID = saveID
	loadGame()
	get_tree().change_scene_to_file("res://hubs/city/city.tscn")
