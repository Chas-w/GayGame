extends Control

@export var title_label: Label
@export var description_label: Label 

func get_title():
  return title_label.text

func set_title(text):
  title_label.text = text

func get_description():
  return description_label.text

func set_description(text):
  description_label.text = text
