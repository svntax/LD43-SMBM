extends Node

var invasionArrived = false
var rebellionStarted = false
var rebellionEnded = false
var soldiersAmountAtEnd = 0

func _ready():
    print("Globals ready")
    pass

func resetGlobals():
    invasionArrived = false
    rebellionStarted = false
    rebellionEnded = false
    soldiersAmountAtEnd = 0

#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
