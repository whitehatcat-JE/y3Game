extends Node

signal gameSaved

var saveFilePath : String = "user://saves/"
var saveListFilePath : String = "user://saves/saveList.tres"

var loadedGlobalData : GlobalData

var activeSaveID : String = "0"

var playerData : PlayerData = PlayerData.new()
var lastSaveTime : int

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
	var currentTime : int = Time.get_unix_time_from_system()
	playerData.playTime += currentTime - lastSaveTime
	lastSaveTime = currentTime
	ResourceSaver.save(playerData, saveFilePath + activeSaveID + ".tres")
	emit_signal("gameSaved")

func loadGame():
	var newPlayerData : PlayerData
	if ResourceLoader.exists(saveFilePath + activeSaveID + ".tres"):
		newPlayerData  = ResourceLoader.load(saveFilePath + activeSaveID + ".tres").duplicate(true)
	else:
		newPlayerData = PlayerData.new()
	playerData.constructor(newPlayerData)
	lastSaveTime = Time.get_unix_time_from_system()

func getGame(saveID):
	if ResourceLoader.exists(saveFilePath + saveID + ".tres"):
		return ResourceLoader.load(saveFilePath + saveID + ".tres").duplicate(true)
	else:
		return PlayerData.new()

func loadAndEnterGame(saveID):
	activeSaveID = saveID
	loadGame()
	saveGame()
	get_tree().change_scene_to_file("res://hubs/city/city.tscn")
