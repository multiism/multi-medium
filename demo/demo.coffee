
for element in document.querySelectorAll "h1, h2, h3, h4, h5, h6, p"
	text = element.innerText
	element.innerHTML = ""
	element.appendChild new MultiMedium text

document.body.appendChild new MultiMedium.Input
