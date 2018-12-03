extends KinematicBody2D

var NORMAL_SPEED = 16
var FRANTIC_SPEED = 24

var spawnPos
var originalPos
var reachedNextPos

var moveSpeed = NORMAL_SPEED
var moveVel
var nextPos
var firstMove

var movingToTargetVillage
var movingBackToCastle
var movingToCastleDoor
var runningAway
var defendingCastle

var targetVillage
var castle
var franticPosOrigin

var wanderTimer

func _ready():
    originalPos = self.global_position
    spawnPos = Vector2()
    reachedNextPos = true
    targetVillage = null
    firstMove = true
    movingToTargetVillage = false
    movingBackToCastle = false
    movingToCastleDoor = false
    runningAway = false
    defendingCastle = false
    
    moveVel = Vector2()
    nextPos = Vector2()
    franticPosOrigin = Vector2()
    
    if(get_parent().name == "InvasionScene"):
        castle = get_parent().find_node("Castle")
    else:
        castle = get_tree().get_root().get_node("Root").find_node("Castle")

func updateOriginalPos():
    originalPos = self.global_position

func sendToCastle():
    movingBackToCastle = true
    moveSpeed = NORMAL_SPEED
    find_node("FranticWanderTimer").stop()
    moveUnitTo(spawnPos)

func sendToCastleFast():
    movingBackToCastle = true
    moveSpeed = FRANTIC_SPEED + 10
    runningAway = true
    find_node("FranticWanderTimer").stop()
    moveUnitTo(castle.global_position + Vector2(0, 18))

func defendCastle():
    defendingCastle = true
    moveSpeed = FRANTIC_SPEED
    find_node("FranticWanderTimer").stop()
    find_node("DefendWanderTimer").start()
    moveUnitTo(originalPos + Vector2(rand_range(-12, 12), rand_range(-12, 12)))

func _process(delta):
    pass

func _physics_process(delta):
    if(!reachedNextPos):
        move_and_slide(moveVel)
    if(self.global_position.distance_to(nextPos) < 2):
        moveVel = Vector2()
        reachedNextPos = true
        if(defendingCastle):
            reachedNextPos = false
            moveUnitTo(originalPos + Vector2(rand_range(-12, 12), rand_range(-12, 12)))
            return
        if(firstMove):
            reachedNextPos = false
            firstMove = false
            movingToTargetVillage = true
            moveUnitTo(targetVillage.global_position + Vector2(rand_range(-24, 24), rand_range(-24, 24)))
        elif(movingToTargetVillage):
            movingToTargetVillage = false
            targetVillage.addSoldier(self)
            startMovingFrantically()
        elif(movingBackToCastle):
            movingBackToCastle = false
            movingToCastleDoor = true
            moveUnitTo(castle.global_position + Vector2(0, 18))
        elif(movingToCastleDoor):
            movingToCastleDoor = false
            castle.increasePopulation(1)
            self.queue_free()
        if(runningAway):
            runningAway = false
            self.queue_free()

func startMovingFrantically():
    franticPosOrigin = self.global_position
    find_node("FranticWanderTimer").start()
    moveSpeed = FRANTIC_SPEED

func moveUnitTo(pos):
    reachedNextPos = false
    nextPos = pos
    moveVel = (nextPos - self.global_position).normalized() * moveSpeed

func _on_FranticWanderTimer_timeout():
    if(!movingBackToCastle):
        moveUnitTo(franticPosOrigin + Vector2(rand_range(-8, 8), rand_range(-8, 8)))

func _on_DefendWanderTimer_timeout():
    moveUnitTo(originalPos + Vector2(rand_range(-12, 12), rand_range(-12, 12)))
