extends Control 

var loadedSaveIDs : Array = []
var loadPageNum : int = 0

func newGamePressed():
	FM.createGame()

func loadGamePressed():
	%settingsMenu.visible = false
	%loadMenu.visible = true
	updateLoadMenu()

func settingsPressed():
	%settingsMenu.visible = true
	%loadMenu.visible = false

func quitPressed(): get_tree().quit();

func updateLoadMenu():
	for save in range(10): %saveMenu.get_node("saveName" + str(save + 1)).visible = false;
	var unorderedSaveIDs : Array = FM.loadedGlobalData.saveIDs
	var unorderedTimeSaves : Dictionary = {}
	for save in unorderedSaveIDs:
		var totalPlayTime : int = FileAccess.get_modified_time(
			FM.saveFilePath + save + ".tres")
		if totalPlayTime in unorderedTimeSaves:
			unorderedTimeSaves[totalPlayTime].append(save)
		else:
			unorderedTimeSaves[totalPlayTime] = [save]
	var orderedTimes : Array = unorderedTimeSaves.keys()
	orderedTimes.sort()
	orderedTimes.reverse()
	loadedSaveIDs = []
	for time in orderedTimes: loadedSaveIDs.append_array(unorderedTimeSaves[time]);
	loadedSaveIDs.slice(loadPageNum * 10, (loadPageNum + 1) * 10)
	for save in range(len(loadedSaveIDs)):
		var targetNode : Node = %saveMenu.get_node("saveName" + str(save + 1))
		targetNode.text = loadedSaveIDs[save].substr(0, 25)
		targetNode.visible = true
		
		var nodeText : String = secToTime(FM.getGame(loadedSaveIDs[save]).playTime)
		nodeText += " | "
		nodeText += toDateTime(Time.get_datetime_dict_from_unix_time(
			FileAccess.get_modified_time(FM.saveFilePath + loadedSaveIDs[save] + ".tres")))
		targetNode.get_node("saveText").text = nodeText
	
	%nextButton.visible = false
	%previousButton.visible = false
	if len(FM.loadedGlobalData.saveIDs) > (loadPageNum + 1) * 10: %nextButton.visible = true
	if loadPageNum > 0: %previousButton.visible = true

func secToTime(seconds:int):
	var minutesRemaining : int = seconds % 3600 / 60
	var hoursRemaining : int = seconds / 3600
	var unformattedResult : String = ""
	if hoursRemaining < 10: unformattedResult += "0%s:";
	else: unformattedResult += "%s:";
	if minutesRemaining < 10: unformattedResult += "0%s";
	else: unformattedResult += "%s";
	return unformattedResult % [hoursRemaining, minutesRemaining]

func toDateTime(timeDict : Dictionary):
	timeDict["hour"] += 12
	if timeDict["minute"] < 10: timeDict["minute"] = "0" + str(timeDict["minute"]);
	if timeDict["hour"] == 0:
		return "12:{minute}am {day}/{month}/{year}".format(timeDict)
	if timeDict["hour"] < 12:
		return "{hour}:{minute}am {day}/{month}/{year}".format(timeDict)
	elif timeDict["hour"] == 12:
		return "12:{minute}pm {day}/{month}/{year}".format(timeDict)
	else:
		timeDict["hour"] -= 12
		return "{hour}:{minute}pm {day}/{month}/{year}".format(timeDict)

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

func previousButtonPressed():
	loadPageNum -= 1
	updateLoadMenu()

func nextButtonPressed():
	loadPageNum += 1
	updateLoadMenu()