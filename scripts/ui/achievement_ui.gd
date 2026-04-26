## Achievement Notification UI
extends CanvasLayer

@onready var notification_container = VBoxContainer.new()
var _notifications: Array[PanelContainer] = []
const NOTIFICATION_LIFETIME: float = 4.0

func _ready() -> void:
	# Setup container
	notification_container.anchor_left = 0.02
	notification_container.anchor_top = 0.05
	notification_container.anchor_right = 0.25
	notification_container.custom_minimum_size = Vector2(300, 0)
	add_child(notification_container)
	
	# Connect to achievements
	Achievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String, title: String, description: String) -> void:
	var notification = PanelContainer.new()
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.15, 0.1, 0.95)
	style_box.border_color = Color(1.0, 0.84, 0.0, 0.8)
	style_box.set_border_enabled_all(true)
	style_box.set_border_width_all(2)
	notification.add_theme_stylebox_override("panel", style_box)
	
	var vbox = VBoxContainer.new()
	
	# Title
	var title_label = Label.new()
	title_label.text = "🏆 %s" % title
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(title_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.custom_minimum_size = Vector2(280, 0)
		desc_label.word_wrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(desc_label)
	
	notification.add_child(vbox)
	notification_container.add_child(notification)
	_notifications.append(notification)
	
	# Animate in
	var tween = create_tween()
	notification.modulate = Color.TRANSPARENT
	tween.tween_property(notification, "modulate", Color.WHITE, 0.3)
	
	# Animate out after delay
	await get_tree().create_timer(NOTIFICATION_LIFETIME).timeout
	
	if notification in _notifications:
		_notifications.erase(notification)
		var fade_tween = create_tween()
		fade_tween.tween_property(notification, "modulate", Color.TRANSPARENT, 0.3)
		await fade_tween.finished
		notification.queue_free()

func show_achievement_list() -> void:
	# Create modal showing all achievements
	var modal = Control.new()
	modal.custom_minimum_size = get_viewport().get_visible_rect().size
	
	var panel = PanelContainer.new()
	panel.anchor_left = 0.1
	panel.anchor_top = 0.1
	panel.anchor_right = 0.9
	panel.anchor_bottom = 0.9
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.98)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	
	# Title
	var title = Label.new()
	title.text = "ACHIEVEMENTS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	title.alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Achievements list
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	var list = VBoxContainer.new()
	
	var achievements = Achievements.get_achievements()
	var unlocked_count = Achievements.get_unlocked_count()
	
	var stats = Label.new()
	stats.text = "Unlocked: %d/%d" % [unlocked_count, achievements.size()]
	stats.alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(stats)
	
	for ach_id in achievements:
		var ach = achievements[ach_id]
		var ach_panel = PanelContainer.new()
		var border_style = StyleBoxFlat.new()
		if ach.get("unlocked", false):
			border_style.bg_color = Color(0.2, 0.3, 0.2, 0.5)
			border_style.border_color = Color(0.0, 1.0, 0.0, 0.5)
		else:
			border_style.bg_color = Color(0.2, 0.2, 0.2, 0.3)
			border_style.border_color = Color(0.5, 0.5, 0.5, 0.2)
		border_style.set_border_enabled_all(true)
		border_style.set_border_width_all(1)
		ach_panel.add_theme_stylebox_override("panel", border_style)
		
		var h_box = HBoxContainer.new()
		var icon = Label.new()
		icon.text = ach.get("icon", "⭐")
		icon.add_theme_font_size_override("font_size", 20)
		h_box.add_child(icon)
		
		var text_box = VBoxContainer.new()
		var ach_title = Label.new()
		ach_title.text = ach["title"]
		ach_title.add_theme_font_size_override("font_size", 12)
		ach_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0) if ach.get("unlocked", false) else Color(0.7, 0.7, 0.7))
		text_box.add_child(ach_title)
		
		var ach_desc = Label.new()
		ach_desc.text = ach["description"]
		ach_desc.add_theme_font_size_override("font_size", 10)
		ach_desc.word_wrap_mode = TextServer.AUTOWRAP_WORD
		text_box.add_child(ach_desc)
		
		h_box.add_child(text_box)
		ach_panel.add_child(h_box)
		list.add_child(ach_panel)
	
	scroll.add_child(list)
	vbox.add_child(scroll)
	panel.add_child(vbox)
	modal.add_child(panel)
	
	get_parent().add_child(modal)
