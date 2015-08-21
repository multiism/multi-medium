
Spanvas = (word)->
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
	spanvas.appendChild document.createTextNode word
	spanvas.appendChild canvas
	spanvas.render = (style)->
		rect = spanvas.getBoundingClientRect()
		canvas.width = rect.width
		canvas.height = rect.height
		canvas.style.display = "inline-block"
		ctx = canvas.getContext "2d"
		ctx.beginPath()
		for x in [0..canvas.width]
			ctx.lineTo x, canvas.height/2 + canvas.height/2 * Math.sin(x) * Math.random(), 10, canvas.height
			if Math.random() < 0.04
				ctx.arc x, canvas.height/2 + canvas.height/2 * Math.sin(x) * Math.random(), 10, Math.PI * Math.random(), Math.PI * Math.random()
		ctx.strokeStyle = style.color
		ctx.stroke()
		spanvas.style.color = "transparent"
	spanvas


@MultiMedium = (source)->
	element = document.createElement "span"
	words = source.split " "
	
	spanvases =
		for word, i in words
			spanvas = Spanvas word
			element.appendChild spanvas
			unless i + 1 is words.length
				element.appendChild document.createTextNode " "
			spanvas
	
	render = ->
		style = getComputedStyle element
		for spanvas in spanvases
			spanvas.render style
	
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
	
	pointers = {}
	strokes = []
	
	render = ->
		ctx.clearRect 0, 0, canvas.width, canvas.height
		ctx.beginPath()
		for {points} in strokes
			ctx.moveTo(points[0].x, points[0].y)
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
	
	window.addEventListener "pointermove", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			e.preventDefault()
			pointer.stroke.points.push point_for e
			render()
	
	window.addEventListener "pointerup", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			if pointer.stroke.points.length < 2 # doesn't make a line
				strokes.splice strokes.indexOf(pointer.stroke), 1
		delete pointers[e.pointerId]
	
	canvas.addEventListener "pointercancel", (e)->
		pointer = pointers[e.pointerId]
		if pointer
			strokes.splice strokes.indexOf(pointer.stroke), 1
		delete pointers[e.pointerId]
	
	setTimeout update_dimensions, 1
	
	element
