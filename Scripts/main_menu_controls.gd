extends Node2D

func _ready():
    Globals.resetGlobals()

func _process(delta):
    if Input.is_action_just_pressed("START_GAME"):
        get_tree().change_scene("res://Scenes/intro_scene.tscn")
