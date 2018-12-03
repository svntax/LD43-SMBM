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
    
    moveVel = Vector2()
    nextPos = Vector2()
    franticPosOrigin = Vector2()
    
    castle = get_tree().get_root().get_node("Root").find_node("Castle")
    
#    wanderTimer = find_node("WanderTimer")
#    wanderTimer.wait_time = rand_range(5, 10)
#    wanderTimer.start()

func updateOriginalPos():
    originalPos = self.global_position

func sendToCastle():
    movingBackToCastle = true
    moveSpeed = NORMAL_SPEED
    find_node("FranticWanderTimer").stop()
    moveUnitTo(spawnPos)

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func _physics_process(delta):
    if(!reachedNextPos):
        move_and_slide(moveVel)
    if(self.global_position.distance_to(nextPos) < 2):
        moveVel = Vector2()
        reachedNextPos = true
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
