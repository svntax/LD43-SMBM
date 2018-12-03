extends KinematicBody2D

var NORMAL_SPEED = 4
var TRAVEL_SPEED = 6 #oxcart speed
var FRANTIC_SPEED = 24
var MOVE_TO_CASTLE_SPEED = 16

var originalPos
var isVillager
var reachedNextPos

var moveSpeed = NORMAL_SPEED
var moveVel
var nextPos

var homeVillage #Reference to original village
var castle

var oxcart

var movingBackToCastle
var travelingToCastle
var travelingBackToVillage

var wanderTimer

func _ready():
    originalPos = self.global_position
    isVillager = true
    reachedNextPos = true
    movingBackToCastle = false
    travelingToCastle = false
    travelingBackToVillage = false
    
    moveVel = Vector2()
    nextPos = Vector2()
    
    wanderTimer = find_node("WanderTimer")
    wanderTimer.wait_time = rand_range(5, 10)
    wanderTimer.start()
    
    pickRandomVillagerSprite()
    
    oxcart = find_node("Oxcart")
    
    homeVillage = get_parent()
    castle = get_tree().get_root().get_node("Root").find_node("Castle")

func pickRandomVillagerSprite():
    var choice = randi() % 6
    find_node("Sprite").frame = choice
    find_node("SpriteUp").frame = choice

func updateOriginalPos():
    originalPos = self.global_position

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
            movingBackToCastle = false
            self.queue_free()
        if(travelingToCastle):
            travelingToCastle = false
            travelingBackToVillage = true
            travelBackToVillage()
        elif(travelingBackToVillage):
            travelingBackToVillage = false
            self.queue_free()

func sendToCastle():
    wanderTimer.stop()
    moveSpeed = MOVE_TO_CASTLE_SPEED
    movingBackToCastle = true
    nextPos = castle.global_position + Vector2(0, 18)
    moveUnitTo(nextPos)

func travelBackToVillage():
    nextPos = homeVillage.global_position + Vector2(0, 8)
    moveUnitTo(nextPos)
    find_node("Oxcart").frame = 1
    if(nextPos.x < self.global_position.x):
        oxcart.flip_h = true
    else:
        oxcart.flip_h = false

func startTraveling():
    wanderTimer.stop()
    find_node("AnimationPlayer").stop()
    find_node("Sprite").hide()
    find_node("SpriteUp").hide()
    find_node("Oxcart").show()
    moveSpeed = TRAVEL_SPEED
    travelingToCastle = true
    nextPos = castle.global_position + Vector2(0, 22)
    moveUnitTo(nextPos)
    if(nextPos.x < self.global_position.x):
        find_node("Oxcart").flip_h = true

func startMovingFrantically():
    moveSpeed = FRANTIC_SPEED
    wanderTimer.stop()
    wanderTimer.wait_time = 0.2
    wanderTimer.start()

func stopMovingFrantically():
    moveSpeed = NORMAL_SPEED
    wanderTimer.wait_time = rand_range(5, 10)

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
        if(homeVillage.currentState == homeVillage.WAR_STATE):
            wanderTimer.wait_time = 0.2
        elif(homeVillage.currentState == homeVillage.PEACE_STATE):
            wanderTimer.wait_time = rand_range(5, 10)
        reachedNextPos = false
        nextPos = originalPos + Vector2(rand_range(-8, 8), rand_range(-8, 8))
        moveVel = (nextPos - self.global_position).normalized() * moveSpeed
