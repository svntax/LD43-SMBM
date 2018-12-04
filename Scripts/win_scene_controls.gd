extends Node2D

var currentFrame
var frames

func _ready():
    SoundHandler.endingTheme.play()
    Globals.resetGlobals()
    currentFrame = 1
    frames = [find_node("Frame1"), find_node("Frame2"), find_node("Frame3"), find_node("Frame4"), find_node("Frame5")]

func _process(delta):
    if Input.is_action_just_pressed("MOVE_TO_NEXT_FRAME"):
        if(currentFrame == frames.size()):
            SoundHandler.endingTheme.stop()
            get_tree().change_scene("res://Scenes/main_menu.tscn")
        else:
            currentFrame += 1
            changeFrameTo(currentFrame)

#Cutscene code is specific to this scene arrangement
func changeFrameTo(n):
    var frame = frames[n-1]
    if(frame):
        for i in range(frames.size()):
            if i == n-1:
                frames[i].show()
            else:
                frames[i].hide()  
