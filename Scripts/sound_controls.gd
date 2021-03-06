extends Node

var mainTheme
var endingTheme
var clickSound
var clashSound01
var clashSound02
var clashSound03
var clashSound04
var clashSound05
var clashSounds
var nooSound

var clashSoundsPlaying = false

func _ready():
    mainTheme = find_node("MainTheme")
    endingTheme = find_node("EndingTheme")
    clickSound = find_node("ClickSound")
    clashSound01 = find_node("ClashSound01")
    clashSound02 = find_node("ClashSound02")
    clashSound03 = find_node("ClashSound03")
    clashSound04 = find_node("ClashSound04")
    clashSound05 = find_node("ClashSound05")
    clashSounds = [clashSound01, clashSound02, clashSound03, clashSound04, clashSound05]
    nooSound = find_node("NooSound")

func startClashSounds():
    if(Globals.invasionArrived):
        return
    if(!clashSoundsPlaying):
        clashSoundsPlaying = true
        find_node("ClashSoundsTimer").start()

func stopClashSounds():
    for village in get_tree().get_nodes_in_group("Villages"):
        if(village.currentState == village.WAR_STATE):
            return
        
    clashSoundsPlaying = false
    find_node("ClashSoundsTimer").stop()

func _on_ClashSoundsTimer_timeout():
    var choice = randi() % 5
    var sfx = clashSounds[choice]
    if(!sfx.playing):
        sfx.play()
        find_node("ClashSoundsTimer").wait_time = rand_range(0.1, 0.3)
