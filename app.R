# prerequisites
require(tidyverse)
require(rnaturalearth)
require(sf)
require(rgeos)
require(leaflet)
require(RColorBrewer)
require(shiny)
require(shinyWidgets)

require(conflicted)
conflict_prefer("addLegend", "leaflet")
conflict_prefer("filter", "dplyr")

url <- "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv"
file <- "data/global-mobility-report.csv"

if(!file.exists(file) | as.Date(file.info(file)$ctime) != Sys.Date()) {
    
    try(download.file(url, destfile = file), silent = T)
}

dat <- read_csv(file) %>%
    filter(is.na(sub_region_1)) %>%
    rename(iso_a2 = country_region_code, country = country_region) %>%
    select(-sub_region_1, -sub_region_2) %>%
    gather("category", "mobility", -iso_a2, -country, -iso_3166_2_code, -census_fips_code, -date, ) %>%
    mutate(category = str_to_title(
        str_replace_all(str_replace(category, "_percent_change_from_baseline", ""), "_", " ")
    ))

data_attribution = paste(
    "<a href = 'https://www.google.com/covid19/mobility/'>Google LLC</a>",
    "Google COVID-19 Community Mobility Reports, Accessed: ",
    Sys.Date()
)
    
sf <- ne_countries(scale = 110, returnclass = "sf") %>%
    mutate(name = admin) %>%
    select(name, iso_a2)

sf_attribution <- "Made with <a href = 'naturalearthdata.com'>Natural Earth</a>"

# app
ui <- bootstrapPage(
    tags$head(tags$style(HTML(
        "html, body {width:100%;height:100%;}",
        "#dropdown-menu-controls {background-color:rgba(255,255,255,0.7) !important;padding:15px;border-radius:10px;}",
        "div.info.legend.leaflet-control {margin-bottom:37px;}"
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
                animate = animationOptions(interval = 500)
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
        bottom = 10, right = 15, 
        materialSwitch(inputId = "leg", label = "Legend", width = 120)
    )
)

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
                    labFormat = labelFormat(prefix = "<", suffix = "%"),
                    opacity = .7,
                    title = "Change in Mobility"
                )
        }
    })
}

shinyApp(ui, server)
