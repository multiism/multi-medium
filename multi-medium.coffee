
all_spanvases = []
selected_spanvas = null
the_input = null
_mm_id_counter = 0

serialize_strokes = (strokes)->
	# console.log "serialize_strokes", strokes
	resolution = 1000
	for {points} in strokes
		a = []
		for point in points
			a.push(
				(~~(point.x * resolution)) / resolution
				(~~(point.y * resolution)) / resolution
			)
		a

deserialize_strokes = (strokes)->
	# console.log "deserialize_strokes", strokes
	for coords in strokes
		points: for i in [0...coords.length] by 2
			{x: coords[i], y: coords[i+1]}

draw_strokes = (strokes, ctx, scale=1)->
	ctx.lineJoin = "round"
	ctx.lineCap = "round"
	ctx.beginPath()
	for {points} in strokes
		ctx.moveTo(points[0].x*scale, points[0].y*scale)
		ctx.lineTo(points[0].x*scale, points[0].y*scale+0.01) if points.length is 1
		ctx.lineTo(point.x*scale, point.y*scale) for point in points
		ctx.points
	ctx.stroke()

Spanvas = (word, data)->
	spanvas = document.createElement "span"
	spanvas.style.position = "relative"
	spanvas.className = "multi-medium-word"
	canvas = document.createElement "canvas"
	canvas.width = canvas.height = 0
	canvas.style.userSelect = "none"
	canvas.style.webkitUserSelect = "none"
	canvas.style.pointerEvents = "none"
	canvas.style.position = "absolute"
	canvas.style.left = "0"
	canvas.style.top = "0"
	
	spanvas.style.cursor = "pointer"
	spanvas.addEventListener "click", (e)->
		spanvas.select()
	
	spanvas.appendChild document.createTextNode word
	spanvas.appendChild canvas
	
	strokes = null
	style = null
	
	spanvas.select = ->
		selected_spanvas?.classList.remove "selected"
		selected_spanvas?.render()
		selected_spanvas = spanvas
		selected_spanvas.classList.add "selected"
		selected_spanvas.render()
		the_input?.clear()
	
	spanvas.hasData = ->
		if strokes then yes else no
	
	spanvas.setData = (data)->
		{strokes} = data
		# if strokes?.length
		# 	spanvas.setAttribute("data-handwriting", JSON.stringify([{strokes: serialize_strokes(strokes)}]))
		spanvas.render()
	
	spanvas.setStyle = (new_style)->
		style = new_style
	
	original_width = null
	spanvas.render = ->
		rect = spanvas.getBoundingClientRect()
		original_width ?= rect.width
		canvas.style.display = "inline-block"
		ctx = canvas.getContext "2d"
		
		if strokes
			scale = rect.height
			
			weight = switch style?.fontWeight
				when "normal" then 400
				when "bold" then 700
				else style?.fontWeight
			
			line_width = 1 + (parseInt(weight) / 400 * scale / 30)
			
			max_x = 0
			min_x = Infinity
			max_y = 0
			min_y = Infinity
			for {points} in strokes
				for point in points
					max_x = Math.max(max_x, point.x)
					min_x = Math.min(min_x, point.x)
					max_y = Math.max(max_y, point.y)
					min_y = Math.min(min_y, point.y)
			
			padding = line_width * 2
			y_offset = ~~Math.min(0, min_y * scale)
			canvas.width = (max_x - min_x) * scale + padding * 2
			canvas.height = Math.max(rect.height, max_y * scale - y_offset + padding * 2)
			
			ctx.lineWidth = line_width
			ctx.strokeStyle = style?.color
			ctx.save()
			ctx.translate(-min_x * scale + padding, -y_offset + padding)
			draw_strokes strokes, ctx, scale
			ctx.restore()
			
			spanvas.style.color = "transparent"
			canvas.style.top = "#{y_offset}px"
			
			if canvas.width isnt rect.width
				spanvas.style.letterSpacing = "#{Math.max(-8, (canvas.width - original_width) / word.length)}px"
	
	setTimeout ->
		spanvas.setData data if data
		json = localStorage["multi-medium:#{spanvas._mm_id}:strokes"]
		if json
			spanvas.setData {strokes: deserialize_strokes JSON.parse json}
	
	spanvas._mm_id = ++_mm_id_counter
	all_spanvases.push spanvas
	spanvas


@MultiMedium = (text, handwriting_data)->
	element = document.createElement "span"
	words = text.split " "
	
	spanvases =
		for word, i in words
			data = handwriting_data?[i]
			if data
				strokes = deserialize_strokes data.strokes
				# console.log "deserialized as", strokes
			spanvas = Spanvas word, {strokes}
			element.appendChild spanvas
			unless i + 1 is words.length
				element.appendChild document.createTextNode " "
			spanvas
	
	render = ->
		style = getComputedStyle element
		for spanvas in spanvases
			spanvas.setStyle style
			spanvas.render()
	
	setTimeout render
	
	element

@MultiMedium.Input = ->
	element = document.createElement "div"
	element.className = "multi-medium-input"
	canvas = document.createElement "canvas"
	canvas.setAttribute "touch-action", "none"
	ctx = canvas.getContext "2d"
	element.appendChild canvas
	
	element_style = null
	update_dimensions = ->
		element_style = getComputedStyle element
		canvas_style = getComputedStyle canvas
		_ = (v)-> if isNaN v then 0 else parseInt v
		pl = _ element_style.paddingLeft
		pr = _ element_style.paddingRight
		pt = _ element_style.paddingTop
		pb = _ element_style.paddingBottom
		cpl = _ canvas_style.paddingLeft
		cpr = _ canvas_style.paddingRight
		cpt = _ canvas_style.paddingTop
		cpb = _ canvas_style.paddingBottom
		cml = _ canvas_style.marginLeft
		cmr = _ canvas_style.marginRight
		cmt = _ canvas_style.marginTop
		cmb = _ canvas_style.marginBottom
		cbl = _ canvas_style.borderLeft
		cbr = _ canvas_style.borderRight
		cbt = _ canvas_style.borderTop
		cbb = _ canvas_style.borderBottom
		canvas.width = element.clientWidth - pl - pr - cml - cmr - cpl - cpr - cbl - cbr
		canvas.height = element.clientHeight - pt - pb - cmt - cmb - cpt - cpb - cbt - cbb
		# WOW, THAT'S A LITTLE BIT UBSURD, DON'T YOU THINK?
		
		render()
	
	pointers = {}
	strokes = []
	undoes = []
	redoes = []
	
	update = ->
		render()
		selected_spanvas.setData {strokes}
		localStorage["multi-medium:#{selected_spanvas._mm_id}:strokes"] = JSON.stringify serialize_strokes strokes
	
	clear = ->
		pointers = {}
		strokes = []
		undoes = []
		redoes = []
		render()
	
	undo = ->
		if undoes.length
			redoes.push serialize_strokes strokes
			strokes = deserialize_strokes undoes.pop()
			update()
	
	redo = ->
		if redoes.length
			undoes.push serialize_strokes strokes
			strokes = deserialize_strokes redoes.pop()
			update()
	
	undoable = ->
		undoes.push serialize_strokes strokes
		redoes = []
	
	render = ->
		baseline = canvas.height * 0.8
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.fillStyle = "rgba(100, 100, 100, 0.1)"
		ctx.font = "#{baseline}px sans-serif"
		selected_word = selected_spanvas?.textContent ? selected_spanvas?.innerText
		ctx.fillText selected_word, 20, baseline
		ctx.strokeStyle = element_style?.color
		ctx.lineWidth = 10
		draw_strokes strokes, ctx, canvas.height
	
	point_for = (e)->
		rect = canvas.getBoundingClientRect()
		canvas_style = getComputedStyle canvas
		cpl = parseInt canvas_style.paddingLeft
		cpt = parseInt canvas_style.paddingTop
		cpl = 0 if isNaN cpl
		cpt = 0 if isNaN cpt
		scale = canvas.height
		x: (e.clientX - rect.left - cpl) / scale
		y: (e.clientY - rect.top - cpt) / scale
	
	canvas.addEventListener "pointerdown", (e)->
		return if e.pointerType is "mouse" and e.button isnt 0
		e.preventDefault()
		undoable()
		stroke = points: [point_for e]
		pointers[e.pointerId] = {stroke, type: e.pointerType}
		strokes.push stroke
		update()
	
	window.addEventListener "pointermove", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			e.preventDefault()
			pointer.stroke.points.push point_for e
			update()
	
	window.addEventListener "pointerup", (e)->
		delete pointers[e.pointerId]
	
	canvas.addEventListener "pointercancel", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			strokes.splice strokes.indexOf(pointer.stroke), 1
		delete pointers[e.pointerId]
	
	# @TODO: localize this event listener
	window.addEventListener "keydown", (e)->
		if e.ctrlKey and not (e.metaKey or e.altKey)
			if e.keyCode is 90 # Z
				if e.shiftKey then redo() else undo()
			if e.keyCode is 89 # Y
				redo()
	
	setTimeout update_dimensions
	window.addEventListener "resize", update_dimensions
	
	setTimeout ->
		for spanvas in all_spanvases when not spanvas.hasData()
			spanvas.select()
			break
	
	if the_input then alert "Multiple MultiMedium.Inputs aren't exactly supported (for a silly reason)"
	the_input = element
	the_input.clear = clear
	
	element
