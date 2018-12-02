extends KinematicBody2D

var originalPos
var reachedNextPos

var moveSpeed = 16
var moveVel
var nextPos
var firstMove
var targetVillage

var wanderTimer

func _ready():
    originalPos = self.global_position
    reachedNextPos = true
    targetVillage = null
    firstMove = true
    
    moveVel = Vector2()
    nextPos = Vector2()
    
#    wanderTimer = find_node("WanderTimer")
#    wanderTimer.wait_time = rand_range(5, 10)
#    wanderTimer.start()

func updateOriginalPos():
    originalPos = self.global_position

#func sendToCastle():
#    isVillager = false
#    isSkeleton = true
#    find_node(spriteName).hide()
#    find_node("SkeletonSprite").show()
#
#    reachedNextPos = false
#    moveSpeed = 12
#    var castle = get_tree().get_root().get_node("Root").find_node("Castle")
#    var angle = rand_range(0, 360)
#    var length = rand_range(24, 32)
#    var nx = length * cos(deg2rad(angle))
#    var ny = length * sin(deg2rad(angle))
#    nextPos = castle.global_position + Vector2(nx, ny)
#    originalPos = nextPos
#    moveVel = (nextPos - self.global_position).normalized() * moveSpeed

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
            moveUnitTo(targetVillage.global_position + Vector2(rand_range(-24, 24), rand_range(-24, 24)))

func moveUnitTo(pos):
    reachedNextPos = false
    nextPos = pos
    moveVel = (nextPos - self.global_position).normalized() * moveSpeed

#func _on_WanderTimer_timeout():
#    wanderTimer.wait_time = rand_range(5, 10)
#    reachedNextPos = false
#    nextPos = originalPos + Vector2(rand_range(-8, 8), rand_range(-8, 8))
#    moveVel = (nextPos - self.position).normalized() * moveSpeed
