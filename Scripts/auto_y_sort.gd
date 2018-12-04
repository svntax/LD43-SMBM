extends Sprite

func _ready():
    pass

func _process(delta):
    ySort()

func ySort():
    var bottom = self.get_texture().get_size().y
    var globalY = self.global_position.y + (bottom / 2)
    #Hard-coded offset for castle object
    if(get_parent().name == "Castle"):
        globalY -= 4
    if(get_parent().name == "Village"):
        globalY = self.global_position.y + 13
    if(globalY < -4000):
        globalY = -4000
    if(globalY > 4000):
        globalY = 4000
    set_z_index(int(globalY))