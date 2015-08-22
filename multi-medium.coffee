
all_spanvases = []
selected_spanvas = null
the_input = null

serialize_strokes = (strokes)->
	# console.log "serialize_strokes", strokes
	for {points} in strokes
		a = []
		for point in points
			a.push point.x, point.y
		a

deserialize_strokes = (strokes)->
	# console.log "deserialize_strokes", strokes
	for coords in strokes
		points: for i in [0...coords.length] by 2
			{x: coords[i], y: coords[i+1]}

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
		# 	spanvas.setAttribute("data-handwriting", JSON.stringify(serialize_strokes(strokes)))
		spanvas.render()
	
	spanvas.setStyle = (new_style)->
		style = new_style
	
	original_width = null
	spanvas.render = ->
		rect = spanvas.getBoundingClientRect()
		original_width ?= rect.width
		canvas.width = rect.width
		canvas.height = rect.height
		canvas.style.display = "inline-block"
		ctx = canvas.getContext "2d"
		
		if strokes
			scale = canvas.height / 150
			max_x = 0
			max_x = Math.max(max_x, point.x) for point in points for {points} in strokes
			canvas.width = max_x * scale + ctx.lineWidth * 2
			
			weight = switch style?.fontWeight
				when "normal" then 400
				when "bold" then 700
				else style?.fontWeight
			
			ctx.lineWidth = 1 + (parseInt(weight) / 400 * canvas.height / 30)
			ctx.lineJoin = "round"
			ctx.lineCap = "round"
			ctx.strokeStyle = style?.color
			ctx.clearRect 0, 0, canvas.width, canvas.height
			ctx.beginPath()
			for {points} in strokes
				ctx.moveTo(points[0].x*scale, points[0].y*scale)
				ctx.lineTo(point.x*scale, point.y*scale) for point in points
				ctx.points
			ctx.stroke()
			spanvas.style.color = "transparent"
			
			if canvas.width isnt rect.width
				spanvas.style.letterSpacing = "#{Math.max(-8, (canvas.width - original_width) / word.length)}px"
	
	setTimeout ->
		spanvas.setData data if data
	
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
	
	setTimeout render, 1
	
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
		pl = parseInt element_style.paddingLeft
		pr = parseInt element_style.paddingRight
		pt = parseInt element_style.paddingTop
		pb = parseInt element_style.paddingBottom
		pl = 0 if isNaN pl
		pr = 0 if isNaN pr
		pt = 0 if isNaN pt
		pb = 0 if isNaN pb
		cpl = parseInt canvas_style.paddingLeft
		cpr = parseInt canvas_style.paddingRight
		cpt = parseInt canvas_style.paddingTop
		cpb = parseInt canvas_style.paddingBottom
		cpl = 0 if isNaN cpl
		cpr = 0 if isNaN cpr
		cpt = 0 if isNaN cpt
		cpb = 0 if isNaN cpb
		cml = parseInt canvas_style.marginLeft
		cmr = parseInt canvas_style.marginRight
		cmt = parseInt canvas_style.marginTop
		cmb = parseInt canvas_style.marginBottom
		cml = 0 if isNaN cml
		cmr = 0 if isNaN cmr
		cmt = 0 if isNaN cmt
		cmb = 0 if isNaN cmb
		cbl = parseInt canvas_style.borderLeft
		cbr = parseInt canvas_style.borderRight
		cbt = parseInt canvas_style.borderTop
		cbb = parseInt canvas_style.borderBottom
		cbl = 0 if isNaN cbl
		cbr = 0 if isNaN cbr
		cbt = 0 if isNaN cbt
		cbb = 0 if isNaN cbb
		canvas.width = element.clientWidth - pl - pr - cml - cmr - cpl - cpr - cbl - cbr
		canvas.height = element.clientHeight - pt - pb - cmt - cmb - cpt - cpb - cbt - cbb
		# WOW, THAT'S A LITTLE BIT UBSURD, DON'T YOU THINK?
		
		render()
	
	pointers = {}
	strokes = []
	
	clear = ->
		pointers = {}
		strokes = []
		render()
	
	render = ->
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.beginPath()
		for {points} in strokes
			ctx.moveTo(points[0].x, points[0].y)
			ctx.lineTo(points[0].x, points[0].y+0.01) if points.length is 1
			ctx.lineTo(point.x, point.y) for point in points
			ctx.points
		ctx.strokeStyle = element_style?.color
		# ctx.lineWidth = element_style?.fontSize / 10
		ctx.lineWidth = 10
		ctx.lineJoin = "round"
		ctx.lineCap = "round"
		ctx.stroke()
	
	point_for = (e)->
		rect = canvas.getBoundingClientRect()
		canvas_style = getComputedStyle canvas
		cpl = parseInt canvas_style.paddingLeft
		cpt = parseInt canvas_style.paddingTop
		cpl = 0 if isNaN cpl
		cpt = 0 if isNaN cpt
		x: e.clientX - rect.left - cpl
		y: e.clientY - rect.top - cpt
	
	canvas.addEventListener "pointerdown", (e)->
		return if e.pointerType is "mouse" and e.button isnt 0
		e.preventDefault()
		stroke = points: [point_for e]
		pointers[e.pointerId] = {stroke, type: e.pointerType}
		strokes.push stroke
		render()
	
	window.addEventListener "pointermove", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			e.preventDefault()
			pointer.stroke.points.push point_for e
			render()
			selected_spanvas.setData {strokes}
	
	window.addEventListener "pointerup", (e)->
		delete pointers[e.pointerId]
	
	canvas.addEventListener "pointercancel", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			strokes.splice strokes.indexOf(pointer.stroke), 1
		delete pointers[e.pointerId]
	
	# button = null
	# element.appendChild button
	
	setTimeout update_dimensions, 1
	window.addEventListener "resize", update_dimensions
	
	element.clear = clear
	
	if the_input then alert "Multiple MultiMedium.Inputs aren't exactly supported (for a silly reason)"
	the_input = element
	element

setTimeout ->
	for spanvas in all_spanvases when not spanvas.hasData()
		spanvas.select()
		break
, 100
