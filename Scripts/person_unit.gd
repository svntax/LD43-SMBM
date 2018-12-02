extends KinematicBody2D

var originalPos
var isVillager
var reachedNextPos

var moveSpeed = 4
var moveVel
var nextPos

var homeVillage #Reference to original village
var castle

var movingBackToCastle

var wanderTimer

func _ready():
    originalPos = self.global_position
    isVillager = true
    reachedNextPos = true
    movingBackToCastle = false
    
    moveVel = Vector2()
    nextPos = Vector2()
    
    wanderTimer = find_node("WanderTimer")
    wanderTimer.wait_time = rand_range(5, 10)
    wanderTimer.start()
    
    pickRandomVillagerSprite()
    
    homeVillage = get_parent().get_parent()
    castle = get_tree().get_root().get_node("Root").find_node("Castle")

func pickRandomVillagerSprite():
    var choice = randi() % 6
    find_node("Sprite").frame = choice

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
        if(movingBackToCastle):
            #TODO should villager also move to spawnPos and then door?
            movingBackToCastle = false
            self.queue_free()

func sendToCastle():
    wanderTimer.stop()
    moveSpeed = 16
    movingBackToCastle = true
    nextPos = castle.global_position + Vector2(0, 18)
    moveUnitTo(nextPos)

func moveUnitTo(nextPos):
    reachedNextPos = false
    moveVel = (nextPos - self.global_position).normalized() * moveSpeed

#func _on_Hitbox_input_event(viewport, event, shape_idx):
#    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
#        if(isVillager):
#            isVillager = false
#            sendToCastle()
#            get_parent().get_parent().reducePopulation(1)

func _on_WanderTimer_timeout():
    if(!movingBackToCastle):
        wanderTimer.wait_time = rand_range(5, 10)
        reachedNextPos = false
        nextPos = originalPos + Vector2(rand_range(-8, 8), rand_range(-8, 8))
        moveVel = (nextPos - self.global_position).normalized() * moveSpeed
