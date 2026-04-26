extends SceneTree
func _init():
    var a: Array[Dictionary] = []
    var b = [{"a": 1}, {"b": 2}] # This is an untyped Array
    
    var json = JSON.new()
    json.parse("[{\"a\": 1}]")
    
    var c = json.data # This is an untyped Array from JSON
    
    a.assign(c) # Correct way
    print("Assign worked")
    
    a = c # Incorrect way?
    print("Direct assignment worked")
    
    quit()
