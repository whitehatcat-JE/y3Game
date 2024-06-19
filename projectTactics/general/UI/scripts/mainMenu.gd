extends Control 
# Variables
var loadedSaveIDs : Array = []
var loadPageNum : int = 0

var currentGameName:String = ""
# Updates SFX volume
func _ready():
	SFX.connectAllButtons()
	Music.playSong("city")
# Opens new game menu
func newGamePressed():
	%gameCreationMenu.visible = true
	%settingsMenu.visible = false
	%loadMenu.visible = false
	updateLoadMenu()
# Opens load game menu
func loadGamePressed():
	%settingsMenu.visible = false
	%gameCreationMenu.visible = false
	%loadMenu.visible = true
	updateLoadMenu()
# Opens settings menu
func settingsPressed():
	%settingsMenu.visible = true
	%loadMenu.visible = false
	%gameCreationMenu.visible = false
# Quits game
func quitPressed(): get_tree().quit();
# Updates displayed saves in load menu
func updateLoadMenu():
	# Hides currently displayed saves
	for save in range(10):
		%saveMenu.get_node("saveName" + str(save + 1)).visible = false;
		%saveMenu.get_node("deleteSave" + str(save + 1)).visible = false;
	# Finds all saves
	var unorderedSaveIDs : Array = FM.loadedGlobalData.saveIDs
	var unorderedTimeSaves : Dictionary = {}
	# Loads save data from disk
	for save in unorderedSaveIDs:
		var totalPlayTime : int = FileAccess.get_modified_time(
			FM.saveFilePath + save + ".tres")
		if totalPlayTime in unorderedTimeSaves:
			unorderedTimeSaves[totalPlayTime].append(save)
		else:
			unorderedTimeSaves[totalPlayTime] = [save]
	# Orders saves by date
	var orderedTimes : Array = unorderedTimeSaves.keys()
	orderedTimes.sort()
	orderedTimes.reverse()
	loadedSaveIDs.clear()
	# Reduces displayed saves to max of 10
	for time in orderedTimes: loadedSaveIDs.append_array(unorderedTimeSaves[time]);
	loadedSaveIDs = loadedSaveIDs.slice(loadPageNum * 10, (loadPageNum + 1) * 10)
	# Displays selected saves
	for save in range(len(loadedSaveIDs)):
		var targetNode : Node = %saveMenu.get_node("saveName" + str(save + 1))
		targetNode.text = loadedSaveIDs[save]
		targetNode.visible = true
		
		var nodeText : String = secToTime(FM.getGame(loadedSaveIDs[save]).playTime)
		nodeText += " | "
		nodeText += toDateTime(Time.get_datetime_dict_from_unix_time(
			FileAccess.get_modified_time(FM.saveFilePath + loadedSaveIDs[save] + ".tres")))
		targetNode.get_node("saveText").text = nodeText
		
		%saveMenu.get_node("deleteSave" + str(save + 1)).visible = true;
	# Shows save navigation buttons if saves exceeds what can be displayed on one page
	%nextButton.visible = false
	%previousButton.visible = false
	if len(FM.loadedGlobalData.saveIDs) > (loadPageNum + 1) * 10: %nextButton.visible = true
	if loadPageNum > 0: %previousButton.visible = true
# Converts seconds to hh:mm:ss format
func secToTime(seconds:int):
	var minutesRemaining : int = seconds % 3600 / 60
	var hoursRemaining : int = seconds / 3600
	var unformattedResult : String = ""
	if hoursRemaining < 10: unformattedResult += "0%s:";
	else: unformattedResult += "%s:";
	if minutesRemaining < 10: unformattedResult += "0%s";
	else: unformattedResult += "%s";
	return unformattedResult % [hoursRemaining, minutesRemaining]
# Converts datetime dictionary to hh:mm dd:mm:yy format
func toDateTime(timeDict : Dictionary):
	timeDict["hour"] += 12
	if timeDict["minute"] < 10: timeDict["minute"] = "0" + str(timeDict["minute"]);
	# Overrides format if hour is 12, as am/pm needs to be switched for these hours
	if timeDict["hour"] == 0:
		return "12:{minute}am {day}/{month}/{year}".format(timeDict)
	if timeDict["hour"] < 12:
		return "{hour}:{minute}am {day}/{month}/{year}".format(timeDict)
	elif timeDict["hour"] == 12:
		return "12:{minute}pm {day}/{month}/{year}".format(timeDict)
	else:
		timeDict["hour"] -= 12
		return "{hour}:{minute}pm {day}/{month}/{year}".format(timeDict)
# Enters selected save
func save1(): FM.loadAndEnterGame(loadedSaveIDs[0]);
func save2(): FM.loadAndEnterGame(loadedSaveIDs[1]);
func save3(): FM.loadAndEnterGame(loadedSaveIDs[2]);
func save4(): FM.loadAndEnterGame(loadedSaveIDs[3]);
func save5(): FM.loadAndEnterGame(loadedSaveIDs[4]);
func save6(): FM.loadAndEnterGame(loadedSaveIDs[5]);
func save7(): FM.loadAndEnterGame(loadedSaveIDs[6]);
func save8(): FM.loadAndEnterGame(loadedSaveIDs[7]);
func save9(): FM.loadAndEnterGame(loadedSaveIDs[8]);
func save10(): FM.loadAndEnterGame(loadedSaveIDs[9]);
# Shows previous page of loaded saves
func previousButtonPressed():
	loadPageNum -= 1
	updateLoadMenu()
# Shows next page of loaded saves
func nextButtonPressed():
	loadPageNum += 1
	updateLoadMenu()
# Creates new save
func createButtonPressed():
	FM.createGame(currentGameName)
# Change newly created save name
func gameNameChanged(newName):
	currentGameName = newName
	if currentGameName in loadedSaveIDs or !currentGameName.is_valid_filename():
		%createGameButton.disabled = true
		return
	%createGameButton.disabled = false

# Deletes given save id
func deleteSave(saveNum:int):
	FM.deleteSave(loadedSaveIDs[saveNum])
	updateLoadMenu()
# Button event for deleting save id
func deleteSave1(): deleteSave(0);
func deleteSave2(): deleteSave(1);
func deleteSave3(): deleteSave(2);
func deleteSave4(): deleteSave(3);
func deleteSave5(): deleteSave(4);
func deleteSave6(): deleteSave(5);
func deleteSave7(): deleteSave(6);
func deleteSave8(): deleteSave(7);
func deleteSave9(): deleteSave(8);
func deleteSave10(): deleteSave(9);
