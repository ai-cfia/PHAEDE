library(shiny)

shinyUI(
  fluidPage(
    shinyjs::useShinyjs(),
    theme = "custom.css",
    tags$head(
      tags$meta(charset = "UTF-8"),
      tags$meta(property = "og:title", content = "PHAEDE"),
      tags$meta(property = "og:description", content = "Plant Health Automated E-commerce Data Extractor"),
      tags$meta(property = "og:image", content = "PHAEDE.png"),
      tags$meta(property = "og:url", content = "//irmmodelling.shinyapps.io/phaede/")
    ),
    tags$div(
      id = "overlay",
      tags$div(
        class = "spinner",
        tags$div(
          class = "bounce1"
        ),
        tags$div(
          class = "bounce2"
        ),
        tags$div(
          class = "bounce3"
        )
      )
    ),
    verticalLayout(
      headerPanel("PHAEDE"),
      wellPanel(
        tags$head(tags$script(src="app.js")),
        textInput("term", NULL),
        actionButton("search", "Search"),
        downloadButton("download", label = "Download Results", class = "disabled")
      ),
      wellPanel(
        tags$h3("Results"),
        tags$hr(),
        uiOutput("result")
      )
    )
  )
)