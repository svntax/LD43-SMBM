extends Node2D

var invasionProgressBar

#TODO change invasion timer back to 120

var invaders
var defendingSoldiers
var invasionSpawnPoints

var invadersAmount
var finalSoldiersAmount

var invadersCount
var soldiersCount

var canClick
var gameWin

var invasionCombatStarted

var invaderObject = load("res://Scenes/soldier.tscn")

func _ready():
    Globals.invasionArrived = false #Hard-coded to allow clashing sounds on invasion scene
    if(!SoundHandler.mainTheme.playing):
        SoundHandler.mainTheme.play()
    invasionProgressBar = find_node("InvasionBar")
    invasionSpawnPoints = []
    invaders = []
    defendingSoldiers = []
    invadersCount = 0
    soldiersCount = 0
    finalSoldiersAmount = 0
    invasionCombatStarted = false
    canClick = false
    gameWin = false
    
    if(self.name == "InvasionScene"):
        #Ugly fix, for some reason 1 extra defender is being spawned
        soldiersCount = 1
        invadersAmount = Globals.INVADERS_AMOUNT
        finalSoldiersAmount = Globals.soldiersAmountAtEnd
        var spawnPoints = find_node("InvasionSources")
        for point in spawnPoints.get_children():
            invasionSpawnPoints.append(point.global_position)

func _process(delta):
    if Globals.rebellionEnded || canClick:
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
        Globals.soldiersAmountAtEnd += get_tree().get_nodes_in_group("Soldiers").size()
        print("Soldiers outside: " + str(get_tree().get_nodes_in_group("Soldiers").size()))
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
    invadersCount += 1
    var invader = invaderObject.instance()
    invader.makeInvader()
    invaders.append(invader)
    add_child(invader)
    var target = get_node("Castle").global_position + Vector2(rand_range(-22, 22), rand_range(-22, 22))
    var choice = randi() % invasionSpawnPoints.size()
    var origin = invasionSpawnPoints[choice] + Vector2(rand_range(-16, 16), rand_range(-16, 16))
    invader.global_position = origin
    invader.spawnPos = origin
    invader.updateOriginalPos()
    invader.invadeCastle(target)

func spawnDefender():
    soldiersCount += 1
    var soldier = invaderObject.instance()
    defendingSoldiers.append(soldier)
    add_child(soldier)
    var origin = get_node("Castle").global_position + Vector2(rand_range(-22, 22), rand_range(-22, 22))
    soldier.global_position = origin
    soldier.spawnPos = origin
    soldier.updateOriginalPos()
    soldier.defendCastle()

func invasionCombatStep():
    if(Globals.invasionEnded):
        return
    print("Soldiers remaining: " + str(defendingSoldiers.size()))
    print("Invaders remaining: " + str(invaders.size()))
    for i in range(5):
        if(invaders.empty()):
            endInvasionCombat(true)
            return
        if(defendingSoldiers.empty()):
            endInvasionCombat(false)
            return
        var invader = invaders.pop_front()
        var soldier = defendingSoldiers.pop_front()
        if(invader):
            invader.queue_free()
        if(soldier):
            soldier.queue_free()

func startInvasionCombat():
    if(invaders.empty()):
        endInvasionCombat(true)
        return
    if(defendingSoldiers.empty()):
        endInvasionCombat(false)
        return
    if(invasionCombatStarted):
        return
    invasionCombatStarted = true
    SoundHandler.startClashSounds()
    if(invadersCount >= invadersAmount && soldiersCount >= finalSoldiersAmount):
        find_node("InvasionSpawnTimer").stop()
    find_node("InvasionCombatTimer").start()

func endInvasionCombat(success):
    SoundHandler.stopClashSounds()
    Globals.invasionEnded = true
    find_node("InvasionCombatTimer").stop()
    gameWin = success
    find_node("InvasionAnimationPlayer").play("battle_end_anim")

func _on_InvasionSpawnTimer_timeout():
    if(invadersCount < invadersAmount):
        spawnInvader()
    if(soldiersCount < finalSoldiersAmount):
        spawnDefender()

func _on_InvasionCombatTimer_timeout():
    invasionCombatStep()

func _on_InvasionAnimationPlayer_animation_finished(anim_name):
    if(anim_name == "battle_end_anim"):
        SoundHandler.mainTheme.stop()
        if(gameWin):
            get_tree().change_scene("res://Scenes/game_win_scene.tscn")
        else:
            find_node("InvasionAnimationPlayer").play("game_over_anim")
    elif(anim_name == "game_over_anim"):
        canClick = true
        SoundHandler.nooSound.play()
