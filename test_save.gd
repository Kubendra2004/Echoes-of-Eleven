extends SceneTree
func _init():
    var err = DirAccess.make_dir_recursive_absolute("user://saves/")
    print("DIR_ERR:", err)
    var file = FileAccess.open("user://saves/save_slot_1.json", FileAccess.WRITE)
    print("FILE:", file != null)
    if file:
        file.store_string("{\"test\": 1}")
    quit()
