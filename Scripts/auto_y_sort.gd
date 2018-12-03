extends Sprite

func _ready():
    # Called when the node is added to the scene for the first time.
    # Initialization here
    pass

func _process(delta):
    ySort()

func ySort():
    var bottom = self.get_texture().get_size().y
    var globalY = self.global_position.y + (bottom / 2)
    #Hard-coded offset for castle object
    if(get_parent().name == "Castle"):
        globalY -= 6
    if(globalY < -4000):
        globalY = -4000
    if(globalY > 4000):
        globalY = 4000
    set_z_index(int(globalY))