extends KinematicBody2D

var originalPos
var isVillager
var reachedNextPos

var moveSpeed = 4
var moveVel
var nextPos

var wanderTimer

func _ready():
    originalPos = self.position
    isVillager = true
    reachedNextPos = true
    
    moveVel = Vector2()
    nextPos = Vector2()
    
    wanderTimer = find_node("WanderTimer")
    wanderTimer.wait_time = rand_range(5, 10)
    wanderTimer.start()

func updateOriginalPos():
    originalPos = self.position

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func _physics_process(delta):
    if(isVillager):
        if(!reachedNextPos):
            move_and_slide(moveVel)
        if(self.position.distance_to(nextPos) < 2):
            moveVel = Vector2()
            reachedNextPos = true

func _on_Hitbox_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
        if(isVillager):
            isVillager = false
            get_parent().get_parent().reducePopulation(1)
            find_node("Sprite").hide()

func _on_WanderTimer_timeout():
    wanderTimer.wait_time = rand_range(5, 10)
    reachedNextPos = false
    nextPos = originalPos + Vector2(rand_range(-8, 8), rand_range(-8, 8))
    moveVel = (nextPos - self.position).normalized() * moveSpeed
