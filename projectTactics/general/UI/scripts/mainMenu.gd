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
	loadedSaveIDs = FM.loadedGlobalData.saveIDs.slice(loadPageNum * 10, (loadPageNum + 1) * 10)
	for save in range(len(loadedSaveIDs)):
		var targetNode : Node = %saveMenu.get_node("saveName" + str(save + 1))
		targetNode.text = loadedSaveIDs[save].substr(0, 25)
		targetNode.visible = true
	
	%nextButton.visible = false
	%previousButton.visible = false
	if len(FM.loadedGlobalData.saveIDs) > (loadPageNum + 1) * 10: %nextButton.visible = true
	if loadPageNum > 0: %previousButton.visible = true

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
