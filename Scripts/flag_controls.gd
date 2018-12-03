extends Node2D

export var targetYOffset = -5

var startingPos
var targetPos
var isWhiteFlag

func _ready():
    startingPos = self.global_position
    targetPos = startingPos + Vector2(0, targetYOffset)
    #Hard-coded
    #If flag needs to lower, white flag, otherwise it's a black flag
    isWhiteFlag = targetYOffset > -10

func updatePos(currentVal, maxVal):
    if(isWhiteFlag):
        if(currentVal < 50):
            self.hide()
        else:
            self.show()
            var percent = (currentVal - 50) / 50
            var totalDist = targetPos.y - startingPos.y
            var dist = totalDist * percent
            self.global_position = startingPos + Vector2(0, dist)
    else:
        var percent = currentVal / maxVal
        if(percent > 1):
            percent = 1
        var totalDist = targetPos.y - startingPos.y
        var dist = totalDist * percent
        self.global_position = startingPos + Vector2(0, dist)