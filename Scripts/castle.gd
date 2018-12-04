extends Node2D

#Based on total population
var GROWTH_RATE = 0.015

#Number of soldiers at the start
var INITIAL_POPULATION = 21.0

#The number of soldiers needed minimum to win
var TARGET_SOLDIER_AMOUNT = Globals.INVADERS_AMOUNT

var population
var prevPopulation
var populationLabel

var soldierObject = load("res://Scenes/soldier.tscn")

func _ready():
    randomize()
    population = INITIAL_POPULATION
    prevPopulation = population
    populationLabel = find_node("PopulationLabel")
    populationLabel.text = "Soldiers: " + str(population)
    find_node("WhiteFlag").updatePos(population, TARGET_SOLDIER_AMOUNT)
    
    if(get_parent().name == "InvasionScene"):
        find_node("GrowthTimer").stop()
        find_node("WhiteFlag").updatePos(Globals.soldiersAmountAtEnd, TARGET_SOLDIER_AMOUNT)

func _process(delta):
    pass

#func addVillager():
#    var villager = villagerObject.instance()
#    get_node("YSort").add_child(villager)
#    villager.translate(Vector2(rand_range(-32, 32), rand_range(-32, 32)))
#    villager.updateOriginalPos()

func spawnSoldier(origin, target, targetVillage):
    SoundHandler.clickSound.play()
    var soldier = soldierObject.instance()
    add_child(soldier)
    soldier.global_position = origin
    soldier.spawnPos = origin
    soldier.updateOriginalPos()
    soldier.targetVillage = targetVillage
    soldier.moveUnitTo(target)
    reducePopulation(1)

func sendSoldiersTo(targetVillage):
    #Send ALL soldiers
    var amount = 1
    if(floor(population) <= 0): #Not enough soldiers
        print("Not enough soldiers")
        return false
    var origin = self.global_position + Vector2(0, 18)
    for i in range(amount):
        spawnSoldier(origin, origin + Vector2(rand_range(-8, 8), rand_range(0, 8)), targetVillage)
    
    return true

func reducePopulation(amount):
    population -= amount
    if(population < 0):
        population = 0
    find_node("WhiteFlag").updatePos(population, TARGET_SOLDIER_AMOUNT)
    populationLabel.text = "Soldiers: " + str(population)

func increasePopulation(amount):
    population += amount
    if(floor(population) > prevPopulation):
        #print(floor(population) - prevPopulation)
#        for i in range(floor(population) - prevPopulation):
#            addVillager()
        prevPopulation = floor(population)
    find_node("WhiteFlag").updatePos(population, TARGET_SOLDIER_AMOUNT)
    populationLabel.text = "Soldiers: " + str(population)

func _on_GrowthTimer_timeout():
    var totalPopulation = 0
    for village in get_tree().get_nodes_in_group("Villages"):
        totalPopulation += village.population
    var amount = totalPopulation * GROWTH_RATE
    increasePopulation(amount)
