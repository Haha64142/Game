class_name SettingsScrollBar
extends MarginContainer
## A class for a scroll bar to use in the settings menu
## 
## When you initialize the class, add a [HScrollBar] and adjust the values there
## to see how it will look. Then adjust the values in this node.
## Also add a [Label] and adjust the values there (ffffffbf is the recomened
## font color).
## [br][br]
## [b]Note:[/b] Remember to set the [method label_text] in this node.

## The text to be displayed on the [Label]. Use curly braces around a section
## you want to evaluate. You can use math expressions, boolean expressions,
## built-in methods, and methods defined in this node. You can use the
## [method value] variable inside the expression.
@export_multiline var label_text := "Value: {value}"
## The name of the setting being changed.
## [br][br]
## [b]Note:[/b] This must be a variable that exists the the global Settings node
@export var setting_name := ""
## The amount to scroll with the mouse wheel. Scrolling down will subtract the
## value and scrolling up will add the value.
## [br][br]
## [b]Note:[/b] negative values scroll the opposite direction
@export var scroll_amount := 5.0
@export var min_value := 0.0
@export var max_value := 100.0
@export var step := 0.0
## The grabber's actual length is the [ScrollBar]'s size multiplied by
## [method grabber_size] over the difference between [method min_value] and
## [method max_value]
@export var grabber_size := 2.5

var scroll_percentage = scroll_amount / (max_value - min_value)

var expressions_text: Array[String] # The string form of the expressions
var texts: Array[String] # A blank entry is for the evaluated expression
var expressions: Array[Expression]

@onready var scroll_bar: HScrollBar = $HScrollBar
@onready var label: Label = $Label

func _ready() -> void:
	scroll_percentage *= ((max_value - min_value) / (max_value + grabber_size - min_value))
	scroll_bar.min_value = min_value
	scroll_bar.max_value = max_value + grabber_size
	scroll_bar.step = step
	scroll_bar.page = grabber_size
	scroll_bar.value = Settings.get(setting_name)
	scroll_bar.gui_input.connect(_on_h_scroll_bar_gui_input)
	scroll_bar.value_changed.connect(_on_h_scroll_bar_value_changed)
	parse_label_text()
	_on_h_scroll_bar_value_changed(scroll_bar.value)


func parse_label_text() -> void:
	var chunk := ""
	label_text += "{"
	for c in label_text:
		if c == "{":
			if chunk != "":
				texts.append(chunk)
				chunk = ""
				continue
		elif c == "}":
			if chunk != "":
				expressions_text.append(chunk)
				texts.append("")
				chunk = ""
				continue
		else:
			chunk += c
	
	for expression in expressions_text:
		expressions.append(Expression.new())
		var error = expressions[-1].parse(expression, ["value"])
		if error != OK:
			print(expressions[-1].get_error_text())
			return


func _on_h_scroll_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				scroll_bar.ratio = (event.global_position.x
						- scroll_bar.global_position.x) / scroll_bar.size.x
			else:
				Settings.set(setting_name, scroll_bar.value)
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP
				or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var speed_modifier := 1.0
			if Input.is_key_pressed(KEY_CTRL):
				speed_modifier *= 0.1
			if Input.is_key_pressed(KEY_SHIFT):
				speed_modifier *= 2
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				speed_modifier *= -1
			scroll_bar.ratio += scroll_percentage / 2 * speed_modifier
			Settings.set(setting_name, scroll_bar.value)
			accept_event()


func _on_h_scroll_bar_value_changed(value: float) -> void:
	var result := ""
	var i: int = 0
	for text in texts:
		if text == "":
			result += str(expressions[i].execute([value], self))
		else:
			result += text
	
	label.text = result
