import re

with open("scenes/investigation/deduction_board.tscn", "r") as f:
    content = f.read()

# We need to reorder the sub resources.
# Find the noise texture block and the gradient block
gradient_block = """[sub_resource type="Gradient" id="Gradient_cork"]
colors = PackedColorArray(0.18, 0.12, 0.08, 1, 0.25, 0.18, 0.12, 1)"""

noise_block = """[sub_resource type="NoiseTexture2D" id="NoiseTexture2D_cork"]
width = 1920
height = 1080
generate_mipmaps = false
seamless = true
color_ramp = SubResource("Gradient_cork")
noise = SubResource("FastNoiseLite_cork")"""

# Remove gradient block from its current place
content = content.replace(gradient_block, "")

# Insert gradient block BEFORE noise block
content = content.replace(noise_block, gradient_block + "\n\n" + noise_block)

with open("scenes/investigation/deduction_board.tscn", "w") as f:
    f.write(content)

