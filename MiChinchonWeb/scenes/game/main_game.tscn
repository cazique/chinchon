[gd_scene load_steps=18 format=3 uid="uid://dvs3xgswrvbfj"]

[ext_resource type="Script" path="res://scripts/game/main_game.gd" id="1_2f6xt"]
[ext_resource type="PackedScene" uid="uid://cax76c32chyra" path="res://scenes/cards/deck_manager.tscn" id="2_k6g4l"]
[ext_resource type="PackedScene" uid="uid://c36jvhysosdkc" path="res://scenes/game/player_hand.tscn" id="3_e8v3q"]
[ext_resource type="Script" path="res://scripts/ui/ui_manager.gd" id="4_3fkst"]
[ext_resource type="Texture2D" uid="uid://dqmq5cuqd6s74" path="res://assets/images/ui/table_background.png" id="5_abdy5"]
[ext_resource type="PackedScene" uid="uid://bkuoxkowaq1lf" path="res://scenes/game/combination_area.tscn" id="6_ihnkl"]
[ext_resource type="Texture2D" uid="uid://c3qpbuo8q784v" path="res://assets/images/ui/pause_button.png" id="7_7hcoe"]
[ext_resource type="FontFile" uid="uid://cbrwe0wv4lsqf" path="res://assets/fonts/Montserrat-Medium.ttf" id="8_dnbrr"]
[ext_resource type="Texture2D" uid="uid://b8h8v8rahjkpx" path="res://assets/images/ui/help_button.png" id="9_0l5lv"]
[ext_resource type="AudioStream" uid="uid://d3xdlc8dko4q0" path="res://assets/audio/music/game_music.ogg" id="10_qfp3g"]

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_kbm52"]
bg_color = Color(0.0784314, 0.243137, 0.0784314, 0.870588)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.309804, 0.611765, 0.309804, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0, 0, 0, 0.2)
shadow_size = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_wv6yy"]
bg_color = Color(0.0392157, 0.121569, 0.0392157, 0.921569)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.215686, 0.427451, 0.215686, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0, 0, 0, 0.2)
shadow_size = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_q5xsd"]
bg_color = Color(0.196078, 0.380392, 0.196078, 0.792157)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.309804, 0.611765, 0.309804, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0, 0, 0, 0.2)
shadow_size = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_f6j8t"]
bg_color = Color(0.0784314, 0.133333, 0.2, 0.870588)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.25098, 0.431373, 0.701961, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0, 0, 0, 0.2)
shadow_size = 4

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_txgje"]
bg_color = Color(0.0980392, 0.321569, 0.188235, 0.92549)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.196078, 0.643137, 0.376471, 1)
corner_radius_top_left = 12
corner_radius_top_right = 12
corner_radius_bottom_right = 12
corner_radius_bottom_left = 12
shadow_color = Color(0, 0, 0, 0.223529)
shadow_size = 6

[sub_resource type="Animation" id="Animation_jfnvp"]
resource_name = "game_start"
length = 2.0
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("Table:modulate")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 1),
"transitions": PackedFloat32Array(0.5, 1),
"update": 0,
"values": [Color(0.5, 0.5, 0.5, 1), Color(1, 1, 1, 1)]
}
tracks/1/type = "value"
tracks/1/imported = false
tracks/1/enabled = true
tracks/1/path = NodePath("PlayerHand:position")
tracks/1/interp = 1
tracks/1/loop_wrap = true
tracks/1/keys = {
"times": PackedFloat32Array(0, 1, 1.5),
"transitions": PackedFloat32Array(0.5, 0.5, 1),
"update": 0,
"values": [Vector2(640, 800), Vector2(640, 600), Vector2(640, 620)]
}
tracks/2/type = "value"
tracks/2/imported = false
tracks/2/enabled = true
tracks/2/path = NodePath("OpponentsContainer:modulate")
tracks/2/interp = 1
tracks/2/loop_wrap = true
tracks/2/keys = {
"times": PackedFloat32Array(0, 0.7, 1.5),
"transitions": PackedFloat32Array(0.5, 0.5, 1),
"update": 0,
"values": [Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(1, 1, 1, 1)]
}
tracks/3/type = "value"
tracks/3/imported = false
tracks/3/enabled = true
tracks/3/path = NodePath("UILayer/GameUI:modulate")
tracks/3/interp = 1
tracks/3/loop_wrap = true
tracks/3/keys = {
"times": PackedFloat32Array(0, 1.5, 2),
"transitions": PackedFloat32Array(0.5, 0.5, 1),
"update": 0,
"values": [Color(1, 1, 1, 0), Color(1, 1, 1, 0), Color(1, 1, 1, 1)]
}

[sub_resource type="AnimationLibrary" id="AnimationLibrary_ihnvq"]
_data = {
"game_start": SubResource("Animation_jfnvp")
}

[node name="MainGame" type="Node2D"]
script = ExtResource("1_2f6xt")

[node name="Table" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.25, 1.25)
texture = ExtResource("5_abdy5")

[node name="DeckManager" parent="Table" instance=ExtResource("2_k6g4l")]
position = Vector2(0, 52)

[node name="CombinationArea" parent="." instance=ExtResource("6_ihnkl")]
position = Vector2(640, 360)

[node name="PlayerHand" parent="." instance=ExtResource("3_e8v3q")]
position = Vector2(640, 620)

[node name="OpponentsContainer" type="Node2D" parent="."]
position = Vector2(640, 360)

[node name="UILayer" type="CanvasLayer" parent="."]
script = ExtResource("4_3fkst")

[node name="GameUI" type="Control" parent="UILayer"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2

[node name="TopBar" type="HBoxContainer" parent="UILayer/GameUI"]
layout_mode = 1
anchors_preset = 10
anchor_right = 1.0
offset_top = 10.0
offset_bottom = 60.0
grow_horizontal = 2
mouse_filter = 2

[node name="LeftSpacer" type="Control" parent="UILayer/GameUI/TopBar"]
layout_mode = 2
size_flags_horizontal = 3
mouse_filter = 2

[node name="RoundIndicator" type="Label" parent="UILayer/GameUI/TopBar"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 22
text = "Ronda 1 de 5"
horizontal_alignment = 1
vertical_alignment = 1

[node name="CenterSpacer" type="Control" parent="UILayer/GameUI/TopBar"]
layout_mode = 2
size_flags_horizontal = 3
mouse_filter = 2

[node name="TurnIndicator" type="Label" parent="UILayer/GameUI/TopBar"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 22
text = "¡Tu turno!"
horizontal_alignment = 1
vertical_alignment = 1

[node name="RightSpacer" type="Control" parent="UILayer/GameUI/TopBar"]
layout_mode = 2
size_flags_horizontal = 3
mouse_filter = 2

[node name="MessageLabel" type="Label" parent="UILayer/GameUI"]
visible = false
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -250.0
offset_top = -25.0
offset_right = 250.0
offset_bottom = 25.0
grow_horizontal = 2
grow_vertical = 2
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 24
text = "¡Comienza el juego!"
horizontal_alignment = 1
vertical_alignment = 1

[node name="PauseButton" type="TextureButton" parent="UILayer/GameUI"]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -60.0
offset_top = 10.0
offset_right = -10.0
offset_bottom = 60.0
grow_horizontal = 0
texture_normal = ExtResource("7_7hcoe")
ignore_texture_size = true
stretch_mode = 5

[node name="HelpButton" type="TextureButton" parent="UILayer/GameUI"]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -120.0
offset_top = 10.0
offset_right = -70.0
offset_bottom = 60.0
grow_horizontal = 0
texture_normal = ExtResource("9_0l5lv")
ignore_texture_size = true
stretch_mode = 5

[node name="ScorePanel" type="PanelContainer" parent="UILayer/GameUI"]
layout_mode = 0
offset_left = 20.0
offset_top = 20.0
offset_right = 220.0
offset_bottom = 200.0
theme_override_styles/panel = SubResource("StyleBoxFlat_kbm52")

[node name="VBoxContainer" type="VBoxContainer" parent="UILayer/GameUI/ScorePanel"]
layout_mode = 2

[node name="TitleLabel" type="Label" parent="UILayer/GameUI/ScorePanel/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 20
text = "Puntuaciones"
horizontal_alignment = 1

[node name="HSeparator" type="HSeparator" parent="UILayer/GameUI/ScorePanel/VBoxContainer"]
layout_mode = 2

[node name="ScoresContainer" type="VBoxContainer" parent="UILayer/GameUI/ScorePanel/VBoxContainer"]
layout_mode = 2
size_flags_vertical = 3

[node name="PauseMenu" type="PanelContainer" parent="UILayer"]
process_mode = 2
visible = false
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -150.0
offset_top = -175.0
offset_right = 150.0
offset_bottom = 175.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_wv6yy")

[node name="VBoxContainer" type="VBoxContainer" parent="UILayer/PauseMenu"]
layout_mode = 2
theme_override_constants/separation = 20

[node name="TitleLabel" type="Label" parent="UILayer/PauseMenu/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 28
text = "Pausa"
horizontal_alignment = 1

[node name="HSeparator" type="HSeparator" parent="UILayer/PauseMenu/VBoxContainer"]
layout_mode = 2

[node name="ResumeButton" type="Button" parent="UILayer/PauseMenu/VBoxContainer"]
layout_mode = 2
size_flags_vertical = 3
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = SubResource("StyleBoxFlat_q5xsd")
text = "Reanudar"

[node name="SettingsButton" type="Button" parent="UILayer/PauseMenu/VBoxContainer"]
layout_mode = 2
size_flags_vertical = 3
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = SubResource("StyleBoxFlat_q5xsd")
text = "Configuración"

[node name="MainMenuButton" type="Button" parent="UILayer/PauseMenu/VBoxContainer"]
layout_mode = 2
size_flags_vertical = 3
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = SubResource("StyleBoxFlat_f6j8t")
text = "Menú Principal"

[node name="GameOverPanel" type="PanelContainer" parent="UILayer"]
process_mode = 2
visible = false
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -250.0
offset_top = -200.0
offset_right = 250.0
offset_bottom = 200.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_txgje")

[node name="VBoxContainer" type="VBoxContainer" parent="UILayer/GameOverPanel"]
layout_mode = 2
theme_override_constants/separation = 15

[node name="TitleLabel" type="Label" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 32
text = "Fin del Juego"
horizontal_alignment = 1

[node name="HSeparator" type="HSeparator" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2

[node name="WinnerLabel" type="Label" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 24
text = "¡Jugador 1 gana!"
horizontal_alignment = 1

[node name="ResultsLabel" type="Label" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2
size_flags_vertical = 3
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 20
text = "Puntuaciones finales:

Jugador 1: 45
CPU 1: 78
CPU 2: 105 (Eliminado)"
horizontal_alignment = 1
vertical_alignment = 1

[node name="HSeparator2" type="HSeparator" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2

[node name="PlayAgainButton" type="Button" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 22
theme_override_styles/normal = SubResource("StyleBoxFlat_q5xsd")
text = "Jugar de Nuevo"

[node name="ExitButton" type="Button" parent="UILayer/GameOverPanel/VBoxContainer"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 22
theme_override_styles/normal = SubResource("StyleBoxFlat_f6j8t")
text = "Menú Principal"

[node name="MessageTimer" type="Timer" parent="UILayer"]
one_shot = true

[node name="SettingsPanel" type="PanelContainer" parent="UILayer"]
process_mode = 2
visible = false
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -200.0
offset_top = -200.0
offset_right = 200.0
offset_bottom = 200.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_wv6yy")

[node name="TooltipPanel" type="PanelContainer" parent="UILayer"]
visible = false
offset_right = 200.0
offset_bottom = 60.0
theme_override_styles/panel = SubResource("StyleBoxFlat_wv6yy")

[node name="TooltipLabel" type="Label" parent="UILayer/TooltipPanel"]
layout_mode = 2
theme_override_fonts/font = ExtResource("8_dnbrr")
theme_override_font_sizes/font_size = 16
text = "Tooltip text"
horizontal_alignment = 1
vertical_alignment = 1
autowrap_mode = 3

[node name="ConfirmationDialog" type="ConfirmationDialog" parent="UILayer"]
initial_position = 2
size = Vector2i(400, 150)
dialog_text = "¿Estás seguro de que quieres volver al menú principal?
Se perderá el progreso actual."

[node name="GameCamera" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimationLibrary_ihnvq")
}

[node name="GameSoundPlayer" type="AudioStreamPlayer" parent="."]

[node name="BackgroundMusic" type="AudioStreamPlayer" parent="."]
stream = ExtResource("10_qfp3g")
volume_db = -10.0
bus = &"Music"