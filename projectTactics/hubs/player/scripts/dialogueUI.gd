extends Control

# EVENT = Trigger Event
# DIALG = Add new dialogue to queue
# FQUIT = End Dialogue
# GSELL = Open Generic Sell Menu

signal dialogueEnded

var dialogue:Dictionary = {
	"caveDwellerIntro":
		["Ah, you must be new around these parts.",
		"If you're in need of supplies, there should be some worn down parts scattered throughout this cave.",
		"Once you've found enough parts to build a mech, come talk to me and I'll see if I can put something together for you."],
	"caveDwellerCheck":
		["Let me have a look at what you've got.../EVENTcaveDwellerAssemble"],
	"caveDwellerFail":
		["Hmmm, you seem to be missing a few parts.",
		"Find me 1x Corroded Head, 1x Corroded Chest Plating, 1x Corroded Sword, 1x Corroded Fire Core, and 1x Corroded Leg.",
		"Then I should be able to put something together for you."],
	#"caveMerchantIntro":
		#["Oh! Hello there. Don't see many people 'round these parts./DIALGcaveMerchant"],
	#"caveMerchantTalk":
		#["Ain't much to chat about down here.",
		#"Sooo.../DIALGcaveMerchant"],
	#"caveMerchant":
		#["How can I help you?/EVENTcaveAssembleUnit/Ask for help/GSELLcaveMerchant/Sell/DIALGcaveMerchantTalk/Small Talk/FQUIT/Nevermind"],
	#"caveAssembleUnitComplete":
		#["Hmm, I might have something lying around here... Ah, take this.",
		#"Well Worn Mech Obtained!/DIALGcaveMerchant"],
	#"caveAssembleUnitFail":
		#["Sorry, looks like you don't have everything needed.",
		#"You need to find 1x Worn Iron Arm/DIALGcaveMerchant"],
	#"caveMerchantSold":
		#["Nice doing business with you./FQUIT"],
	#"caveMerchantDenied":
		#["If you change your mind feel free to come back anytime./FQUIT"],
	"unitAssemblerIntro":
		["The mech assembly system. You can build or deconstruct mechs here./DIALGunitAssembler"],
	"unitAssembler":
		["The mech assembly system./EVENTbuildUnit/Build Unit/EVENTdeconstructUnit/Deconstruct Unit/FQUIT/Leave"],
	"fishermanIntro":
		["You look like you have potential.",
		"Here, take my old fishing rod, may it serve you well./EVENTgiveFishingRod",
		"Fishing Rod Acquired! Press left click when looking at water to begin fishing."],
	"fisherman":
		["If you're looking for places to fish, I believe the cave system beneath the city is as good a place as any."],
	"cityBuyerIntro":
		["Well hello down there!",
		"If you're looking to sell goods, you've come to the right place./GSELLcityBuyer/Sell/FQUIT/Nevermind"],
	"cityBuyer":
		["Looking to sell?/GSELLcityBuyer/Sell/FQUIT/Nevermind"],
	"cityBuyerDenied":
		["Come back anytime!"],
	"cityBuyerSold":
		["Pleasure doing business."]
}

var queuedDialogue:Array[String] = []
var queuedActions:Array[String] = []
var canSkip:bool = false

@onready var responseBoxes:Array[Button] = [%response1, %response2, %response3, %response4]

func _ready():
	GS.eventFinished.connect(nextLine)
	GS.triggerDialogue.connect(appendDialogue)

func _process(delta):
	if Input.is_action_just_pressed("interact") and !responseBoxes[0].visible and canSkip:
		if len(queuedActions) > 0: executeAction(queuedActions[0]);
		else: nextLine();

func startDialogue(identifier:String):
	visible = true
	SFX.playCloseMenu()
	appendDialogue(identifier)

func nextLine():
	visible = true
	if len(queuedDialogue) == 0:
		endDialogue()
		return
	queuedActions.clear()
	canSkip = false
	for responseBox in responseBoxes: responseBox.visible = false;
	var rawLine:String = queuedDialogue.pop_front() + "/"
	var curString:String = ""
	var idxNum:int = 0
	for char:String in rawLine:
		if char == "/":
			if idxNum == 0: %dialogueText.text = curString;
			elif idxNum % 2 == 0:
				responseBoxes[idxNum / 2 - 1].text = curString
				responseBoxes[idxNum / 2 - 1].visible = true
			else: queuedActions.append(curString);
			idxNum += 1
			curString = ""
			continue
		curString += char
	if idxNum < 3: %dialogueText.text += " [wave]▼";
	await get_tree().create_timer(0.1).timeout
	canSkip = true

func executeAction(action:String):
	match action.substr(0, 5):
		"EVENT":
			canSkip = false
			visible = false
			GS.emit_signal("event", action.substr(5, -1), "")
		"DIALG":
			appendDialogue(action.substr(5, -1))
		"FQUIT":
			endDialogue()
		"GSELL":
			visible = false
			%sellMenu.enable(action.substr(5, -1))

func endDialogue():
	visible = false
	SFX.playCloseMenu()
	queuedActions.clear()
	queuedDialogue.clear()
	for responseBox in responseBoxes: responseBox.visible = false;
	emit_signal("dialogueEnded")
	process_mode = Node.PROCESS_MODE_DISABLED

func appendDialogue(identifier:String):
	for line:String in dialogue[identifier]:
		queuedDialogue.append(line)
	nextLine()

func startCustomDialogue(customDialogue:Array):
	for line:String in customDialogue:
		queuedDialogue.append(line)
	nextLine()

func response1Pressed(): executeAction(queuedActions[0]);
func response2Pressed(): executeAction(queuedActions[1]);
func response3Pressed(): executeAction(queuedActions[2]);
func response4Pressed(): executeAction(queuedActions[3]);
