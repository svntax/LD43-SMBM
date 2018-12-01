extends Node2D

var originalPos
var isVillager

func _ready():
    originalPos = self.position
    isVillager = true

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func _on_Hitbox_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
        if(isVillager):
            isVillager = false
            get_parent().get_parent().reducePopulation(1)
            find_node("Sprite").hide()
