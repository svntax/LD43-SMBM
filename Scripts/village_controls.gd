extends Node2D

var GROWTH_RATE = 0.02
var DEATH_RATE = 0.33
var FEAR_GROWTH_ON_ATTACK = 0.15

var population
var prevPopulation
var populationLabel

var currentFear
var maxFear = 100
var fearLabel

var castle

var lifebar

var isBeingTargeted

var villagerObject = load("res://Scenes/villager.tscn")

func _ready():
    randomize()
    population = 10
    currentFear = 10
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

#Amount must be integer
func reducePopulation(amount):
    population -= amount
    
    var amountLeft = amount
    var i = 0
    var villagers = get_tree().get_nodes_in_group("Villagers")
    while(amountLeft > 0 && i < villagers.size()):
        var v = villagers[i]
        i += 1
        if(v.homeVillage == self):
            v.queue_free()
            amountLeft -= 1
    
    if(population < 0):
        population = 0
    populationLabel.text = "Population: " + str(population)
    lifebar.value = population

func increasePopulation(amount):
    population += amount
    if(floor(population) > prevPopulation):
        #print(floor(population) - prevPopulation)
        for i in range(floor(population) - prevPopulation):
            addVillager()
        prevPopulation = floor(population)
        
    populationLabel.text = "Population: " + str(population)
    
    if(lifebar.max_value < population):
        lifebar.max_value = population
    lifebar.value = population

func attackVillage():
    var amount = population * DEATH_RATE
    reducePopulation(round(amount))
    increaseFear(maxFear * FEAR_GROWTH_ON_ATTACK)
    isBeingTargeted = false

func _on_GrowthTimer_timeout():
    var amount = population * GROWTH_RATE
    #print(str(population) + " vs " + str(floor(population + amount)))
    increasePopulation(amount)

func _on_ClickArea_input_event(viewport, event, shape_idx):
    if(event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
        if(!isBeingTargeted): #TODO prevent spamming attack
            #isBeingTargeted = true
            var castle = get_parent().find_node("Castle")
            var successfulAttack = castle.sendSoldiersTo(self)
            #TODO immediate for now
            if(successfulAttack):
                attackVillage()
