extends Node2D

var population
var populationLabel
var lifebar

var villagerObject = load("res://Scenes/villager.tscn")

func _ready():
    randomize()
    population = 10
    populationLabel = find_node("PopulationLabel")
    lifebar = find_node("Lifebar")
    populationLabel.text = str(population)
    for i in range(population):
        var villager = villagerObject.instance()
        get_node("YSort").add_child(villager)
        villager.translate(Vector2(rand_range(-32, 32), rand_range(-32, 32)))
        villager.updateOriginalPos()

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func reducePopulation(amount):
    population -= amount
    if(population < 0):
        population = 0
    populationLabel.text = str(population)
    lifebar.value = population
