extends Control

# EVENT = Trigger Event
# DIALG = Add new dialogue to queue
# FQUIT = End Dialogue

signal dialogueEnded

var dialogue:Dictionary = {
	"caveMerchantIntro":
		["Oh! Hello there. Don't see many people 'round these parts./DIALGcaveMerchant"],
	"caveMerchantTalk":
		["Ain't much to chat about down here.",
		"Sooo.../DIALGcaveMerchant"],
	"caveMerchant":
		["How can I help you?/EVENTcaveAssembleUnit/Assemble Unit/EVENTcaveSell/Sell/DIALGcaveMerchantTalk/Small Talk/FQUIT/Nevermind"],
	"caveMerchantGoodbye":
		["Give this a try.",
		"Moonstone Unit Obtained!/DIALGcaveMerchant"]
}

var queuedDialogue:Array[String] = []
var queuedActions:Array[String] = []
var canSkip:bool = false

@onready var responseBoxes:Array[Button] = [%response1, %response2, %response3, %response4]

func _ready():
	GS.eventFinished.connect(nextLine)
	GS.event.connect(eventTriggered)

func eventTriggered(identifier:String, value):
	if identifier == "caveAssembleUnit":
		appendDialogue("caveMerchantGoodbye")
	nextLine()

func _process(delta):
	if Input.is_action_just_pressed("interact") and !responseBoxes[0].visible and canSkip:
		if len(queuedActions) > 0: executeAction(queuedActions[0]);
		else: nextLine();

func startDialogue(identifier:String):
	visible = true
	appendDialogue(identifier)
	nextLine()

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
			nextLine()
		"FQUIT":
			endDialogue()

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

func response1Pressed(): executeAction(queuedActions[0]);
func response2Pressed(): executeAction(queuedActions[1]);
func response3Pressed(): executeAction(queuedActions[2]);
func response4Pressed(): executeAction(queuedActions[3]);