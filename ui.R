ui <- bootstrapPage(
	tags$head(tags$style(HTML(
		'html, body {width:100%;height:100%; font-family:Consolas, "Ubuntu Mono", monospace;}',
		"#dropdown-menu-controls {background-color:rgba(255,255,255,0.7) !important;padding:15px;border-radius:10px;}",
		'div.info.legend.leaflet-control {margin-bottom:37px; font-family:Consolas, "Ubuntu Mono", monospace;}'
	))),
	leafletOutput("map", width = "100%", height = "100%"),
	absolutePanel(
		top = 20, right = 20,
		dropdownButton(
			titlePanel("COVID-19 Community Mobility Reports"),
			inputId = "controls",
			tooltip = tooltipOptions(placement = "left", title = "Controls"),
			right = T, circle = T, icon = icon("gear"),
			sliderInput(
				"dat", "Select Date", 
				min = min(dat$date), max = max(dat$date), value = max(dat$date),
				animate = animationOptions(interval = 1250)
			),
			selectInput(
				"cat", "Select Category", 
				choices = unique(dat$category), selected = "Retail And Recreation"
			),
			helpText(
				"See ", a(
					href = "https://www.google.com/covid19/mobility/data_documentation.html", 
					"data documentation",
					target="_blank"
				),
				" for category definitions. Note: Location accuracy and the understanding",
				" of categorized places varies from region to region."
			),
			selectInput(
				"pal", "Choose Palette", 
				choices = rownames(subset(brewer.pal.info, category == "div")), selected = "PiYG"
			)
		)
	), 
	absolutePanel(
		top = 20, right = 80,
		circleButton(
			inputId = "about", icon = icon("question"),
			onclick ="window.open('https://www.oliverfritz.de/portfolio/covid-19-community-mobility/', '_blank')"
		)
	),
	absolutePanel(
		bottom = 10, right = 15, 
		materialSwitch(inputId = "leg", label = "Legend", width = 120)
	)
)