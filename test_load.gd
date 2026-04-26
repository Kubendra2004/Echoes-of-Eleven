extends SceneTree
func _init():
    var scene = load("res://scenes/chapter1/crime_scene.tscn")
    if scene:
        print("LOAD SUCCESS")
    else:
        print("LOAD FAILED")
    quit()
