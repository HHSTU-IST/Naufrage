param(
    [string]$Root = 'D:\GitHub\naufrage'
)

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$gameConfigGd = @'
extends Resource
class_name GameConfig

@export var max_day: int = 15
@export var starting_food: int = 15
@export var survival_food_cost: int = 1
@export var rescue_food_cost: int = 1
@export var move_food_cost: int = 1
@export var true_ending_route: String = "west"
'@

$characterDataGd = @'
extends Resource
class_name CharacterData

@export var id: String = ""
@export var display_name: String = ""
@export var route_id: String = ""
@export var portrait_path: String = ""
@export var initial_state: int = 0
@export var reliability: float = 0.5
@export var description: String = ""
'@

$routeDataGd = @'
extends Resource
class_name RouteData

@export var id: String = ""
@export var display_name: String = ""
@export var days_total: int = 0
@export var description: String = ""
@export var return_allowed: bool = true
'@

$dialogueDataGd = @'
extends Resource
class_name DialogueData

@export var id: String = ""
@export var speaker_id: String = ""
@export var text: String = ""
@export var dream_only: bool = false
@export var clue_id: String = ""
@export var reliability_delta: int = 0
'@

$endingDataGd = @'
extends Resource
class_name EndingData

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var image_path: String = ""
'@

$inputSetupGd = @'
extends Node
class_name InputSetup

func _ready() -> void:
	_register("move_forward", KEY_W)
	_register("move_back", KEY_S)
	_register("talk", KEY_E)
	_register("rescue", KEY_R)
	_register("sleep", KEY_SPACE)
	_register("save", KEY_F5)
	_register("load", KEY_F8)


func _register(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)
'@

$gameConfigTres = @'
[gd_resource type="Resource" script_class="GameConfig" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/game_config.gd" id="1"]

[resource]
script = ExtResource("1")
max_day = 15
starting_food = 15
survival_food_cost = 1
rescue_food_cost = 1
move_food_cost = 1
true_ending_route = "west"
'@

function New-CharacterTres {
    param(
        [string]$Path,
        [string]$Id,
        [string]$DisplayName,
        [string]$RouteId,
        [string]$PortraitPath,
        [int]$InitialState,
        [double]$Reliability,
        [string]$Description
    )

    $content = @"
[gd_resource type="Resource" script_class="CharacterData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/character_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = "$Id"
display_name = "$DisplayName"
route_id = "$RouteId"
portrait_path = "$PortraitPath"
initial_state = $InitialState
reliability = $Reliability
description = "$Description"
"@
    Write-TextFile $Path $content
}

function New-RouteTres {
    param(
        [string]$Path,
        [string]$Id,
        [string]$DisplayName,
        [int]$DaysTotal,
        [string]$Description,
        [bool]$ReturnAllowed
    )

    $content = @"
[gd_resource type="Resource" script_class="RouteData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/route_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = "$Id"
display_name = "$DisplayName"
days_total = $DaysTotal
description = "$Description"
return_allowed = $($ReturnAllowed.ToString().ToLower())
"@
    Write-TextFile $Path $content
}

$dialogueSample = @'
[gd_resource type="Resource" script_class="DialogueData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/dialogue_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = "intro_west_01"
speaker_id = "fisher_west"
text = "海面今天不太对。"
dream_only = false
clue_id = "clue_sea_normal"
reliability_delta = 1
'@

$endingSample = @'
[gd_resource type="Resource" script_class="EndingData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/ending_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = "ending_truth"
title = "真结局"
description = "你识破了梦与现实的边界。"
image_path = "res://assets/endings/ending_truth.png"
'@

Write-TextFile (Join-Path $Root 'data/game_config.gd') $gameConfigGd
Write-TextFile (Join-Path $Root 'data/character_data.gd') $characterDataGd
Write-TextFile (Join-Path $Root 'data/route_data.gd') $routeDataGd
Write-TextFile (Join-Path $Root 'data/dialogue_data.gd') $dialogueDataGd
Write-TextFile (Join-Path $Root 'data/ending_data.gd') $endingDataGd
Write-TextFile (Join-Path $Root 'scripts/autoload/input_setup.gd') $inputSetupGd
Write-TextFile (Join-Path $Root 'data/config/game_config.tres') $gameConfigTres
New-CharacterTres (Join-Path $Root 'data/characters/fisher_west.tres') 'fisher_west' '西侧渔民' 'west' 'res://assets/portraits/portrait_fisher_west.png' 0 0.5 '西边路线的信息源。'
New-CharacterTres (Join-Path $Root 'data/characters/fisher_north.tres') 'fisher_north' '北侧渔民' 'north' 'res://assets/portraits/portrait_fisher_north.png' 0 0.5 '北边路线的信息源。'
New-CharacterTres (Join-Path $Root 'data/characters/fisher_east.tres') 'fisher_east' '东侧渔民' 'east' 'res://assets/portraits/portrait_fisher_east.png' 0 0.5 '东边路线的信息源。'
New-RouteTres (Join-Path $Root 'data/routes/route_west.tres') 'west' '西' 5 '最短路线。' $true
New-RouteTres (Join-Path $Root 'data/routes/route_north.tres') 'north' '北' 8 '中等路线。' $true
New-RouteTres (Join-Path $Root 'data/routes/route_east.tres') 'east' '东' 14 '最长路线。' $true
Write-TextFile (Join-Path $Root 'data/dialogues/intro_west_01.tres') $dialogueSample
Write-TextFile (Join-Path $Root 'data/endings/ending_truth.tres') $endingSample

$projectPath = Join-Path $Root 'project.godot'
$project = [System.IO.File]::ReadAllText($projectPath)
if ($project -notmatch 'InputSetup=') {
    $autoloadBlock = @'
[autoload]

GameState="*res://scripts/autoload/game_state.gd"
SaveManager="*res://scripts/autoload/save_manager.gd"
ConfigDB="*res://scripts/autoload/config_db.gd"
EventBus="*res://scripts/autoload/event_bus.gd"
InputSetup="*res://scripts/autoload/input_setup.gd"
'@
    $project = [regex]::Replace($project, '\[autoload\][\s\S]*?(?=\r?\n\[|\z)', $autoloadBlock + "`r`n", 1)
}
[System.IO.File]::WriteAllText($projectPath, $project, [System.Text.UTF8Encoding]::new($false))
