extends Node2D

var population
var prevPopulation
var populationLabel

var soldierObject = load("res://Scenes/soldier.tscn")

func _ready():
    randomize()
    population = 10
    prevPopulation = population
    populationLabel = find_node("PopulationLabel")
    populationLabel.text = str(population)
#    for i in range(population):
#        addVillager()

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

#func addVillager():
#    var villager = villagerObject.instance()
#    get_node("YSort").add_child(villager)
#    villager.translate(Vector2(rand_range(-32, 32), rand_range(-32, 32)))
#    villager.updateOriginalPos()

func spawnSoldier(origin, target):
    var soldier = soldierObject.instance()
    find_node("YSort").add_child(soldier)
    soldier.global_position = origin
    soldier.updateOriginalPos()
    soldier.moveUnitTo(target)

func sendSoldiersTo(targetVillage):
    #Send ALL soldiers
    var amount = floor(population)
    var origin = self.global_position + Vector2(0, 16)
    var angleStart = 30
    var angleEnd = 150
    var angleDelta = (angleEnd - angleStart) / amount
    print(angleDelta)
    var length = 16
    for i in range(amount):
        var nx = length * cos(deg2rad(angleStart + (i * angleDelta)))
        var ny = length * sin(deg2rad(angleStart + (i * angleDelta)))
        spawnSoldier(origin, origin + Vector2(nx, ny))

func reducePopulation(amount):
    population -= amount
    if(population < 0):
        population = 0
    populationLabel.text = str(population)

func increasePopulation(amount):
    population += amount
    if(floor(population) > prevPopulation):
        #print(floor(population) - prevPopulation)
#        for i in range(floor(population) - prevPopulation):
#            addVillager()
        prevPopulation = floor(population)
        
    populationLabel.text = str(population)

func _on_GrowthTimer_timeout():
    var amount = population * 0.02
    #print(str(population) + " vs " + str(floor(population + amount)))
    increasePopulation(amount)
