extends Control

# EVENT = Trigger Event
# DIALG = Add new dialogue to queue
# FQUIT = End Dialogue
# GSELL = Open Generic Sell Menu

signal dialogueEnded

var dialogue:Dictionary = {
	"caveMerchantIntro":
		["Oh! Hello there. Don't see many people 'round these parts./DIALGcaveMerchant"],
	"caveMerchantTalk":
		["Ain't much to chat about down here.",
		"Sooo.../DIALGcaveMerchant"],
	"caveMerchant":
		["How can I help you?/EVENTcaveAssembleUnit/Assemble Unit/GSELLcaveMerchant/Sell/DIALGcaveMerchantTalk/Small Talk/FQUIT/Nevermind"],
	"caveAssembleUnitComplete":
		["Give this a try.",
		"Moonstone Unit Obtained!/DIALGcaveMerchant"],
	"caveAssembleUnitFail":
		["Sorry, looks like you don't have everything needed.",
		"You need to find 1x Worn Iron Arm/DIALGcaveMerchant"],
	"caveMerchantSold":
		["Nice doing business with you./FQUIT"],
	"caveMerchantDenied":
		["If you change your mind feel free to come back anytime./FQUIT"]
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
