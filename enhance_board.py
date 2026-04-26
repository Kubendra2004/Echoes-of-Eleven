import re

with open("scenes/investigation/deduction_board.tscn", "r") as f:
    content = f.read()

# Add a sub_resource for noise texture
noise_texture = """
[sub_resource type="FastNoiseLite" id="FastNoiseLite_cork"]
noise_type = 3
frequency = 0.8
fractal_type = 2
fractal_octaves = 2

[sub_resource type="NoiseTexture2D" id="NoiseTexture2D_cork"]
width = 1920
height = 1080
generate_mipmaps = false
seamless = true
color_ramp = SubResource("Gradient_cork")
noise = SubResource("FastNoiseLite_cork")

[sub_resource type="Gradient" id="Gradient_cork"]
colors = PackedColorArray(0.18, 0.12, 0.08, 1, 0.25, 0.18, 0.12, 1)
"""

if "NoiseTexture2D_cork" not in content:
    # Inject after the ext_resources
    first_node_idx = content.find("\n[node ")
    content = content[:first_node_idx] + "\n" + noise_texture + "\n" + content[first_node_idx:]

# Replace ColorRect with TextureRect
color_rect = """[node name="CorkboardBG" type="ColorRect" parent="."]
unique_name_in_owner = true
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.12, 0.1, 0.08, 1)"""

texture_rect = """[node name="CorkboardBG" type="TextureRect" parent="."]
unique_name_in_owner = true
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = SubResource("NoiseTexture2D_cork")
stretch_mode = 1"""

content = content.replace(color_rect, texture_rect)

with open("scenes/investigation/deduction_board.tscn", "w") as f:
    f.write(content)

