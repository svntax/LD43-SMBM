extends Node2D

var population
var prevPopulation
var populationLabel
var lifebar
var isBeingTargeted

var villagerObject = load("res://Scenes/villager.tscn")

func _ready():
    randomize()
    population = 10
    prevPopulation = population
    isBeingTargeted = false
    populationLabel = find_node("PopulationLabel")
    lifebar = find_node("Lifebar")
    populationLabel.text = str(population)
    for i in range(population):
        addVillager()

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func addVillager():
    var villager = villagerObject.instance()
    get_node("YSort").add_child(villager)
    villager.translate(Vector2(rand_range(-32, 32), rand_range(-32, 32)))
    villager.updateOriginalPos()

func reducePopulation(amount):
    population -= amount
    if(population < 0):
        population = 0
    populationLabel.text = str(population)
    lifebar.value = population

func increasePopulation(amount):
    population += amount
    if(floor(population) > prevPopulation):
        #print(floor(population) - prevPopulation)
        for i in range(floor(population) - prevPopulation):
            addVillager()
        prevPopulation = floor(population)
        
    populationLabel.text = str(population)
    
    if(lifebar.max_value < population):
        lifebar.max_value = population
    lifebar.value = population

func _on_GrowthTimer_timeout():
    var amount = population * 0.02
    #print(str(population) + " vs " + str(floor(population + amount)))
    increasePopulation(amount)

func _on_ClickArea_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
        if(!isBeingTargeted):
            isBeingTargeted = true
            var castle = get_parent().find_node("Castle")
            castle.sendSoldiersTo(self)
