extends Node

var invasionArrived = false
var rebellionStarted = false
var rebellionEnded = false
var invasionEnded = false
var soldiersAmountAtEnd = 0

var INVADERS_AMOUNT = 20

func _ready():
    print("Globals ready")
    pass

func resetGlobals():
    invasionArrived = false
    rebellionStarted = false
    rebellionEnded = false
    invasionEnded = false
    soldiersAmountAtEnd = 0