extends Node2D

var invasionProgressBar

#TODO change invasion timer back to 120

var invaders
var defendingSoldiers
var invasionSpawnPoints

var invadersAmount
var finalSoldiersAmount

var invaderObject = load("res://Scenes/soldier.tscn")

func _ready():
    SoundHandler.mainTheme.play()
    invasionProgressBar = find_node("InvasionBar")
    invasionSpawnPoints = []
    invaders = []
    defendingSoldiers = []
    finalSoldiersAmount = 0
    
    if(self.name == "InvasionScene"):
        invadersAmount = Globals.INVADERS_AMOUNT
        finalSoldiersAmount = Globals.soldiersAmountAtEnd
        var spawnPoints = find_node("InvasionSources")
        for point in spawnPoints.get_children():
            invasionSpawnPoints.append(point.global_position)

func _process(delta):
    if Globals.rebellionEnded:
        if Input.is_action_just_pressed("MOVE_TO_NEXT_FRAME"):
            SoundHandler.mainTheme.stop()
            get_tree().change_scene("res://Scenes/main_menu.tscn")

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
        print("Soldiers at end: " + str(Globals.soldiersAmountAtEnd))
        get_tree().change_scene("res://Scenes/invasion_scene.tscn")
    elif(anim_name == "rebellion_anim"):
        Globals.rebellionEnded = true
        SoundHandler.mainTheme.stop()
        SoundHandler.nooSound.play()

func spawnInvader():
    var invader = invaderObject.instance()
    invader.isInvader = true
    invaders.append(invader)
    add_child(invader)
    var target = get_node("Castle").global_position + Vector2(rand_range(-48, 48), rand_range(-48, 48))
    var choice = randi() % invasionSpawnPoints.size()
    var origin = invasionSpawnPoints[choice] + Vector2(rand_range(-16, 16), rand_range(-16, 16))
    invader.global_position = origin
    invader.spawnPos = origin
    invader.updateOriginalPos()
    invader.invadeCastle(target)

func spawnDefender():
    var soldier = invaderObject.instance()
    defendingSoldiers.append(soldier)
    add_child(soldier)
    var origin = get_node("Castle").global_position + Vector2(rand_range(-22, 22), rand_range(-22, 22))
    soldier.global_position = origin
    soldier.spawnPos = origin
    soldier.updateOriginalPos()
    soldier.defendCastle()

func invasionCombatStep():
    pass

func _on_InvasionSpawnTimer_timeout():
#    if(invaders.size() < invadersAmount):
#        spawnInvader()
    if(defendingSoldiers.size() < finalSoldiersAmount):
        spawnDefender()
    if(invaders.size() >= invadersAmount && defendingSoldiers.size() >= finalSoldiersAmount):
        find_node("InvasionSpawnTimer").stop()
        find_node("InvasionCombatTimer").start()

func _on_InvasionCombatTimer_timeout():
    invasionCombatStep()
