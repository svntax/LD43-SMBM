extends Node2D

var GROWTH_RATE = 0.035
var DEATH_RATE = 0.33
#var FEAR_GROWTH_ON_ATTACK = 0.15

var FEAR_GROWTH_WHILE_AT_WAR = 0.05
var FEAR_GROWTH_PER_REMAINING_SOLDIER = 0.06
var FEAR_DECREASE_WHILE_AT_PEACE = 0.018

#Must be floats
var SOLDIERS_PER_VILLAGER_DEATH = 5.0
var VILLAGERS_PER_SOLDIER_DEATH = 15.0

var TRAVELING_VILLAGERS_PERCENT = 0.2

var population
var prevPopulation
var populationLabel

var currentFear
var maxFear = 100
var fearLabel
var attackingSoldiers
var localVillagers

var PEACE_STATE = 0
var WAR_STATE = 1
var currentState

var castle

var lifebar

var isBeingTargeted

var villagerObject = load("res://Scenes/villager.tscn")

func _ready():
    randomize()
    population = 10
    currentFear = 40
    localVillagers = []
    attackingSoldiers = []
    currentState = PEACE_STATE
    prevPopulation = population
    isBeingTargeted = false
    populationLabel = find_node("PopulationLabel")
    fearLabel = find_node("FearLabel")
    lifebar = find_node("Lifebar")
    populationLabel.text = "Population: " + str(population)
    fearLabel.text = "Fear: " + str(round(currentFear)) + "%"
    for i in range(population):
        addVillager()
    
    castle = get_parent().find_node("Castle")

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func addVillager():
    var villager = villagerObject.instance()
    get_node("YSort").add_child(villager)
    villager.translate(Vector2(rand_range(-22, 22), rand_range(-22, 22)))
    villager.updateOriginalPos()
    localVillagers.append(villager)

func addTravelingVillager():
    var villager = villagerObject.instance()
    get_node("YSort").add_child(villager)
    villager.translate(Vector2(rand_range(-12, 12), rand_range(0, 8)))
    villager.updateOriginalPos()
    villager.startTraveling()

func reduceFear(amount):
    currentFear -= amount
    if(currentFear < 0):
        currentFear = 0
        #TODO rebellion?
    fearLabel.text = "Fear: " + str(currentFear) + "%"

func increaseFear(amount):
    currentFear += amount
    if(currentFear > 100):
        currentFear = 100
    fearLabel.text = "Fear: " + str(currentFear) + "%"

func reducePopulation(amount):
    population -= amount
    if(population < 0):
        population = 0
    if(floor(population) < prevPopulation):
        var count = prevPopulation - floor(population)
        while(count > 0 && !localVillagers.empty()):
            var v = localVillagers.pop_front()
            v.queue_free()
            count -= 1
    
#    var amountLeft = amount
#    var i = 0
#    #var villagers = get_tree().get_nodes_in_group("Villagers")
#    while(amountLeft > 0 && !localVillagers.empty()):
#        var v = localVillagers.pop_front()
#        i += 1
#        #if(v.homeVillage == self):
#        v.queue_free()
#        amountLeft -= 1
    prevPopulation = floor(population)
    populationLabel.text = "Population: " + str(population)
    lifebar.value = population

func sendVillagerToCastle(villager):
    villager.sendToCastle()
    population -= 1
    if(population < 0):
        population = 0
    prevPopulation = floor(population)
    populationLabel.text = "Population: " + str(population)
    lifebar.value = population

func increasePopulation(amount):
    population += amount
    #print(str(prevPopulation) + " vs " + str(floor(population)))
    if(floor(population) > prevPopulation):
        #print(floor(population) - prevPopulation)
        for i in range(floor(population) - prevPopulation):
            addVillager()
        prevPopulation = floor(population)
        
    populationLabel.text = "Population: " + str(population)
    
    if(lifebar.max_value < population):
        lifebar.max_value = population
    lifebar.value = population

func runCombatStep():
    print("Combat step!")
    var soldiersDeathAmount = localVillagers.size() / VILLAGERS_PER_SOLDIER_DEATH
    var villagersDeathAmount = attackingSoldiers.size() / SOLDIERS_PER_VILLAGER_DEATH
    print("Villagers death: " + str(villagersDeathAmount))
    print("Soldiers death: " + str(soldiersDeathAmount))
    reducePopulation(villagersDeathAmount)
    if(floor(population) <= 0):
        population = 0 #Killed too many villagers, village is now empty
        sendRemainingSoldiersToCastle()
    #reduceSoldiers(soldierDeathAmount)
    #TODO what if 0 soldiers left

func addSoldier(soldierObj):
    if(currentState == PEACE_STATE):
        currentState = WAR_STATE
        find_node("CombatTimer").start()
        find_node("FearGrowthTimer").start()
    attackingSoldiers.append(soldierObj)
    print("Num soldiers attacking: " + str(attackingSoldiers.size()))
    if(currentFear >= 50 || localVillagers.empty()):
        sendRemainingSoldiersToCastle()

func sendRemainingSoldiersToCastle():
    find_node("FearGrowthTimer").stop()
    find_node("CombatTimer").stop()
    currentState = PEACE_STATE
    var count = attackingSoldiers.size()
    #var i = 0
    #var localVillagers = get_tree().get_nodes_in_group("Villagers")
    while(count > 0 && population >= 1 && !localVillagers.empty()):
        var v = localVillagers.pop_front()
        #i += 1
        if(v.homeVillage == self):
            increaseFear(FEAR_GROWTH_PER_REMAINING_SOLDIER * maxFear)
            sendVillagerToCastle(v)
            count -= 1
    while(!attackingSoldiers.empty()):
        var soldier = attackingSoldiers.pop_front()
        if(soldier != null && !soldier.movingBackToCastle):
            soldier.sendToCastle()

func _on_GrowthTimer_timeout():
    if(currentState == PEACE_STATE):
        var amount = population * GROWTH_RATE
        #print(str(population) + " vs " + str(floor(population + amount)))
        increasePopulation(amount)
        reduceFear(maxFear * FEAR_DECREASE_WHILE_AT_PEACE)

func _on_FearGrowthTimer_timeout():
    if(currentState == WAR_STATE):
        increaseFear(maxFear * FEAR_GROWTH_WHILE_AT_WAR)
        if(currentFear >= 50):
            sendRemainingSoldiersToCastle()          

func _on_ClickArea_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
#        if(!isBeingTargeted): #TODO check if necessary
#            #isBeingTargeted = true
        var successfulAttack = castle.sendSoldiersTo(self)

func _on_TravelTimer_timeout():
    var amount = floor(population * TRAVELING_VILLAGERS_PERCENT)
    if(amount > 0):
        for i in range(amount):
            addTravelingVillager()

func _on_CombatTimer_timeout():
    runCombatStep()
