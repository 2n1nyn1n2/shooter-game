extends CanvasLayer
class_name PerformanceMonitorUI

@onready var fps_label: Label = %FPSLabel
@onready var memory_label: Label = %MemoryLabel
@onready var draw_calls_label: Label = %DrawCallsLabel
@onready var object_count_label: Label = %ObjectCountLabel
@onready var vram_label: Label = %VRAMLabel
@onready var note_label: Label = %NoteLabel


func _ready():
	pass


func _process(_delta: float) -> void:
	# 1. FPS
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: %d" % fps

	# 2. Static RAM (CPU Memory used by the engine)
	var mem_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_mb = mem_bytes / 1024.0 / 1024.0
	memory_label.text = "CPU Mem: %.2f MB" % mem_mb

	# 3. Video RAM (VRAM used by textures and meshes)
	var vram_bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var vram_mb = vram_bytes / 1024.0 / 1024.0
	vram_label.text = "VRAM: %.2f MB" % vram_mb

	# 4. Draw Calls (How many batches sent to the GPU this frame)
	var draw_calls = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	draw_calls_label.text = "Draw Calls: %s" % format_with_commas(draw_calls)

	var objects = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	object_count_label.text = "Active Objects: %s" % format_with_commas(objects)


# Helper function to inject commas into a number string
func format_with_commas(number: int) -> String:
	var num_str = str(abs(number))
	var result = ""
	var count = 0

	# Loop backwards through the string, adding a comma every 3 digits
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result

	if number < 0:
		result = "-" + result
	return result


func _on_note_changed(text: String):
	note_label.text = text
