
Spanvas = (word)->
	spanvas = document.createElement "span"
	spanvas.style.position = "relative"
	spanvas.className = "word"
	canvas = document.createElement "canvas"
	canvas.width = canvas.height = 0
	canvas.style.userSelect = "none"
	canvas.style.webkitUserSelect = "none"
	canvas.style.pointerEvents = "none"
	span = document.createElement "span"
	span.style.position = "absolute"
	span.style.left = "0"
	span.style.top = "0"
	span.style.userSelect = "none"
	span.style.webkitUserSelect = "none"
	span.style.pointerEvents = "none"
	span.appendChild canvas
	spanvas.appendChild document.createTextNode word
	spanvas.appendChild span
	spanvas.render = (style)->
		rect = spanvas.getBoundingClientRect()
		canvas.width = rect.width
		canvas.height = rect.height
		canvas.style.display = "inline-block"
		ctx = canvas.getContext "2d"
		ctx.fillStyle = style.color
		for x in [0..canvas.width-5] by 10
			ctx.fillRect x, canvas.height * (if Math.random() < 0.4 then 0.5 else 0.1), 10, canvas.height
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
	
	setTimeout render, 100
	
	element
