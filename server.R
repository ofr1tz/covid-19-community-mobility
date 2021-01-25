server <- function(input, output, session) {
	
	# filter data and join with polygons
	selection <- reactive({
		f <- dat %>% filter(category == input$cat, date == input$dat) 
		sf %>% left_join(f, by = c("iso_a2" = "iso_a2"))
	})
	
	# make palette
	make_pal <- reactive({
		brewer_pal <- brewer.pal(10, input$pal)
		colorFactor(
			palette = c(brewer_pal, darken(brewer_pal[10], .67)), 
			domain = selection()$bin,
			na.color = "#FFFFFF00"
		)
	})
	
	# prepare map
	output$map <- renderLeaflet({
		leaflet() %>% 
			addProviderTiles(providers$CartoDB.Positron) %>%
			addTiles(urlTemplate = "", attribution = data_attribution) %>%
			addTiles(urlTemplate = "", attribution = sf_attribution) %>%
			setView(10, 25, zoom = 3)
	})
	
	# update map
	observe({
		pal <- make_pal()
		leafletProxy("map", data = selection()) %>% 
			addPolygons(
				layerId = ~iso_a2, # each polygon will get its name attribute as layerId, thus, polygons are updated rather than plotted on top of each other
				label = ~paste0(name, ": ", case_when(mobility > 0 ~ "+", mobility < 0 ~ "-", TRUE ~ ""), abs(mobility), "%"),
				fillColor = ~pal(bin), 
				stroke = F, fillOpacity = .7
			) 
	})
	
	# show legend
	observe({
		proxy <- leafletProxy("map", data = selection())
		proxy %>% clearControls()
		
		if(!input$leg) {
			pal <- make_pal()
			proxy %>%
				addLegend(
					position = "bottomright",
					pal = pal,
					labels = labels,
					values = ~bin,
					opacity = .7,
					title = "Change in Mobility (%)"
				)
		}
	})
}