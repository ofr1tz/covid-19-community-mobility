server <- function(input, output, session) {
	
	# filter data and join with polygons
	selection <- reactive({
		f <- dat %>% filter(category == input$cat, date == input$dat)
		sf %>% left_join(f, by = c("iso_a2" = "iso_a2"))
	})
	
	# make palette
	make_pal <- reactive({
		max <- max(c(100, selection()$mobility), na.rm = T)
		bins <- c(max, seq(80, -100, -20))
		pal <- colorBin(brewer.pal(11, input$pal), bins = bins, na.color = "#FFFFFF00")
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
		leafletProxy("map" , data = selection()) %>% 
			addPolygons(
				layerId = ~iso_a2, # each polygon will get its name attribute as layerId, thus, polygons are updated rather than plotted on top of each other
				label = ~paste0(name, ": ", mobility, "%"),
				fillColor = ~pal(mobility), 
				stroke = F, fillOpacity = .7
			) 
	})
	
	# show legend
	labels <- c(
		">= +80 %", "+60 \U2012 < +80 %", "+40 \U2012 < +60 %", "+20 \U2012 < +40 %", "0 \U2012 < +20 %",
		 "-20 \U2012 < 0 %", "-40 \U2012 < -20 %", "-20 \U2012 < -40 %", "-60 \U2012 < -40 %", "-80 \U2012 < -60 %", "< -80 %"
	)
	
	observe({
		proxy <- leafletProxy("map", data = selection())
		proxy %>% clearControls()
		
		if(!input$leg) {
			pal <- make_pal()
			proxy %>%
				addLegend(
					position = "bottomright",
					pal = pal,
					values = ~mobility,
					labels = labels, 
					# labFormat = labelFormat(prefix = "<", suffix = "%"),
					opacity = .7,
					title = "Change in Mobility"
				)
		}
	})
}