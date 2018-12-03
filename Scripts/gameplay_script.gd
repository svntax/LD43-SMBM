extends Node2D

var invasionProgressBar

func _ready():
    SoundHandler.mainTheme.play()
    invasionProgressBar = find_node("InvasionBar")

func _process(delta):
    if Globals.rebellionEnded:
        if Input.is_action_just_pressed("MOVE_TO_NEXT_FRAME"):
            SoundHandler.mainTheme.stop()
            get_tree().change_scene("res://Scenes/intro_scene.tscn")

func startRebellion():
    if(!Globals.rebellionStarted):
        Globals.rebellionStarted = true
        get_node("InvasionTimer").stop()
        var villages = get_tree().get_nodes_in_group("Villages")
        for village in villages:
            village.rebel()
        get_node("AnimationPlayer").play("rebellion_anim")

func _on_InvasionTimer_timeout():
    if(Globals.rebellionStarted):
        return
    invasionProgressBar.value += 1
    if(invasionProgressBar.value >= invasionProgressBar.max_value):
        print("START THE INVASION!")
        Globals.invasionArrived = true
        SoundHandler.stopClashSounds()
        find_node("InvasionTimer").stop()
        var villages = get_tree().get_nodes_in_group("Villages")
        for village in villages:
            village.hideVillagers()
        Globals.soldiersAmountAtEnd = get_node("Castle").population
        #Animation
        get_node("UI").get_node("InvasionLabel").hide()
        get_node("UI").get_node("ArrivedLabel").show()
        get_node("AnimationPlayer").play("fadeout_anim")

func _on_AnimationPlayer_animation_finished(anim_name):
    if(anim_name == "fadeout_anim"):
        print("Change to end cutscene")
        print("Soldiers at end: " + str(Globals.soldiersAmountAtEnd))
    elif(anim_name == "rebellion_anim"):
        Globals.rebellionEnded = true
