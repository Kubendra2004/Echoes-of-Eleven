import re

with open("scenes/chapter1/crime_scene.tscn", "r") as f:
    content = f.read()

# 1. Define new sub resources for shapes
new_shapes = """
[sub_resource type="BoxShape3D" id="BoxShape3D_wall_back"]
size = Vector3(12, 3.5, 0.2)

[sub_resource type="BoxShape3D" id="BoxShape3D_wall_side"]
size = Vector3(0.2, 3.5, 10)

[sub_resource type="BoxShape3D" id="BoxShape3D_counter"]
size = Vector3(3, 1, 0.8)

[sub_resource type="BoxShape3D" id="BoxShape3D_couch"]
size = Vector3(2.5, 0.7, 1)

[sub_resource type="BoxShape3D" id="BoxShape3D_table"]
size = Vector3(1.2, 0.05, 0.8)

[sub_resource type="CylinderShape3D" id="CylinderShape3D_table_leg"]
height = 0.4
radius = 0.03
"""

# Inject these at the end of the sub_resources, right before the first [node
first_node_idx = content.find("\n[node ")
content = content[:first_node_idx] + new_shapes + content[first_node_idx:]

# 2. Append StaticBody3D children to each MeshInstance3D if they don't have one
# Mesh instances that need collisions: BackWall, LeftWall, RightWall, FrontWall, Ceiling, KitchenCounter, Couch, Table, TableLeg1, TableLeg2, TableLeg3, TableLeg4
nodes_to_collide = {
    "BackWall": "BoxShape3D_wall_back",
    "LeftWall": "BoxShape3D_wall_side",
    "RightWall": "BoxShape3D_wall_side",
    "FrontWall": "BoxShape3D_wall_back",
    "Ceiling": "BoxShape3D_floor",
    "KitchenCounter": "BoxShape3D_counter",
    "Couch": "BoxShape3D_couch",
    "Table": "BoxShape3D_table",
    "TableLeg1": "CylinderShape3D_table_leg",
    "TableLeg2": "CylinderShape3D_table_leg",
    "TableLeg3": "CylinderShape3D_table_leg",
    "TableLeg4": "CylinderShape3D_table_leg",
}

for node_name, shape_id in nodes_to_collide.items():
    # Find the node block
    pattern = r'\[node name="' + node_name + r'" type="MeshInstance3D" parent="([^"]+)"\]\n(?:[^\n]*\n)*?(?=\n\[node|\Z)'
    match = re.search(pattern, content)
    if match:
        full_match = match.group(0)
        parent_path = match.group(1)
        
        # Make sure we don't duplicate
        if f'parent="{parent_path}/{node_name}"' not in content:
            # We add a StaticBody3D to this node
            collision_nodes = f"""
[node name="StaticBody3D" type="StaticBody3D" parent="{parent_path}/{node_name}"]

[node name="CollisionShape3D" type="CollisionShape3D" parent="{parent_path}/{node_name}/StaticBody3D"]
shape = SubResource("{shape_id}")
"""
            content = content[:match.end()] + collision_nodes + content[match.end():]

with open("scenes/chapter1/crime_scene.tscn", "w") as f:
    f.write(content)
