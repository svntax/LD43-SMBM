extends Node2D

var GROWTH_RATE = 0.035
var DEATH_RATE = 0.33

var FEAR_GROWTH_WHILE_AT_WAR = 0.5 #based on current number of attacking soldiers
var FEAR_GROWTH_PER_REMAINING_SOLDIER = 0.06
var FEAR_DECREASE_WHILE_AT_PEACE = 0.018

#Number of villagers at start
var INITIAL_POPULATION = 10
var INITIAL_FEAR = 40

#Must be decimal numbers
var SOLDIERS_PER_VILLAGER_DEATH = 5.0
var VILLAGERS_PER_SOLDIER_DEATH = 20.0

var TRAVELING_VILLAGERS_PERCENT = 0.2

var population
var prevPopulation
var populationLabel

var currentFear
var maxFear = 100
var fearLabel
var attackingSoldiers
var soldiersAmount
var localVillagers
var travelersLeft

var PEACE_STATE = 0
var WAR_STATE = 1
var currentState

var castle

var lifebar

var isBeingTargeted

var villagerObject = load("res://Scenes/villager.tscn")

func _ready():
    randomize()
    population = INITIAL_POPULATION
    currentFear = INITIAL_FEAR
    localVillagers = []
    attackingSoldiers = []
    soldiersAmount = 0
    travelersLeft = 0
    currentState = PEACE_STATE
    prevPopulation = population
    isBeingTargeted = false
    populationLabel = find_node("PopulationLabel")
    fearLabel = find_node("FearLabel")
    lifebar = find_node("Lifebar")
    populationLabel.text = "Population: " + str(population)
    fearLabel.text = "Fear: " + str(round(currentFear)) + "%"
    find_node("WhiteFlag").updatePos(currentFear, maxFear)
    for i in range(population):
        addVillager()
    
    castle = get_parent().find_node("Castle")

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass

func addVillager():
    var villager = villagerObject.instance()
    #get_node("YSort").add_child(villager)
    add_child(villager)
    villager.translate(Vector2(rand_range(-18, 18), rand_range(-18, 18)))
    villager.updateOriginalPos()
    localVillagers.append(villager)

func addTravelingVillager():
    var villager = villagerObject.instance()
    #get_node("YSort").add_child(villager)
    add_child(villager)
    villager.translate(Vector2(0, 16))
    villager.updateOriginalPos()
    villager.startTraveling()

func reduceFear(amount):
    currentFear -= amount
    if(currentFear < 0):
        currentFear = 0
        #TODO rebellion
    find_node("WhiteFlag").updatePos(currentFear, maxFear)
    fearLabel.text = "Fear: " + str(currentFear) + "%"

func increaseFear(amount):
    currentFear += amount
    if(currentFear > 100):
        currentFear = 100
    find_node("WhiteFlag").updatePos(currentFear, maxFear)
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

#For visual effect only
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
    #Calculate fear first
    if(currentState == WAR_STATE):
        var amount = FEAR_GROWTH_WHILE_AT_WAR * attackingSoldiers.size()
        increaseFear(amount)
        if(currentFear >= 50):
            sendRemainingSoldiersToCastle()
            return
    print("==COMBAT STEP==")
    var soldiersDeathAmount = localVillagers.size() / VILLAGERS_PER_SOLDIER_DEATH
    var villagersDeathAmount = attackingSoldiers.size() / SOLDIERS_PER_VILLAGER_DEATH
    print("Villagers death: " + str(villagersDeathAmount))
    print("Soldiers death: " + str(soldiersDeathAmount))
    #TODO order of deaths matters, right now villagers are damaged first
    reducePopulation(villagersDeathAmount)
    if(floor(population) <= 0):
        population = 0 #Killed too many villagers, village is now empty
        sendRemainingSoldiersToCastle()
    killSoldiers(soldiersDeathAmount)
    if(attackingSoldiers.empty()):
        soldiersAmount = 0
        sendRemainingSoldiersToCastle()
    print("Remaining villagers (int, float): " + str(localVillagers.size()) + ", " + str(population))
    print("Remaining soldiers (int, float): " + str(attackingSoldiers.size()) + ", " + str(soldiersAmount))

func changeToWar():
    SoundHandler.startClashSounds()
    currentState = WAR_STATE
    find_node("CombatTimer").start()
    find_node("FearGrowthTimer").start()
    for v in localVillagers:
        v.startMovingFrantically()    
    #DEBUG
    find_node("StateLabel").text = "WAR"

func changeToPeace():
    SoundHandler.stopClashSounds()
    print("==COMBAT END==")
    currentState = PEACE_STATE
    find_node("FearGrowthTimer").stop()
    find_node("CombatTimer").stop()
    for v in localVillagers:
        v.stopMovingFrantically()
    #DEBUG
    find_node("StateLabel").text = "PEACE"

func addSoldier(soldierObj):
    if(currentState == PEACE_STATE):
        changeToWar()
    attackingSoldiers.append(soldierObj)
    soldiersAmount += 1
    #print("Num soldiers attacking (int, float): " + str(attackingSoldiers.size()) + ", " + str(soldiersAmount))
    if(currentFear >= 50 || localVillagers.empty()):
        sendRemainingSoldiersToCastle()

func killSoldiers(amount):
    soldiersAmount -= amount
    if(soldiersAmount < 0):
        soldiersAmount = 0
    if(floor(soldiersAmount) < attackingSoldiers.size()):
        var count = attackingSoldiers.size() - floor(soldiersAmount)
        while(count > 0 && !attackingSoldiers.empty()):
            var s = attackingSoldiers.pop_front()
            s.queue_free()
            count -= 1

func sendRemainingSoldiersToCastle():
    changeToPeace()
    var count = floor(attackingSoldiers.size() / 2)
    var halfPopulation = population / 2
    #var i = 0
    #var localVillagers = get_tree().get_nodes_in_group("Villagers")
    while(count > 0 && population >= halfPopulation && !localVillagers.empty()):
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
    soldiersAmount = 0

func _on_GrowthTimer_timeout():
    if(currentState == PEACE_STATE):
        var amount = population * GROWTH_RATE
        #print(str(population) + " vs " + str(floor(population + amount)))
        increasePopulation(amount)
        reduceFear(maxFear * FEAR_DECREASE_WHILE_AT_PEACE)

func _on_FearGrowthTimer_timeout():
    pass
    #Changed so that fear grows at the same rate as combat steps
#    if(currentState == WAR_STATE):
#        var amount = FEAR_GROWTH_WHILE_AT_WAR * attackingSoldiers.size()
#        increaseFear(amount)
#        if(currentFear >= 50):
#            sendRemainingSoldiersToCastle()

func _on_ClickArea_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
#        if(!isBeingTargeted): #TODO check if necessary
#            #isBeingTargeted = true
        var successfulAttack = castle.sendSoldiersTo(self)

func _on_TravelTimer_timeout():
    var amount = floor(population * TRAVELING_VILLAGERS_PERCENT)
    if(amount > 0):
        travelersLeft = amount
        find_node("TravelTimer").stop()
        find_node("SingleTravelTimer").start()

func _on_CombatTimer_timeout():
    runCombatStep()

func _on_SingleTravelTimer_timeout():
    travelersLeft -= 1
    addTravelingVillager()
    if(travelersLeft <= 0):
        travelersLeft = 0
        find_node("SingleTravelTimer").stop()
        find_node("TravelTimer").wait_time = 25 + (randi() % 7)
        find_node("TravelTimer").start()
