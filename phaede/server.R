library(shiny)
library(fastrtext)

model_fasttext <- load_model("model_fasttext.bin")

percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

shinyServer(
  function(input, output) {
    predict_fasttext <- reactive({
      predict(model_fasttext,
              sentences = tolower(input$list_title_description))
    })
    output$result <- renderUI({
      if(!is.null(input$list_title_description)) {
        predictions <- predict_fasttext()
        shinyjs::enable("download")
        lapply(1:length(input$list_title), function(i) {
          if(names(predictions[[i]]) == "Low") {
            if(i == length(input$list_title)) {
              tags$div(
                tags$h4(
                  tags$a(input$list_title[i],
                         href = input$list_url[i],
                         target="_blank")
                ),
                tags$p(
                  HTML(
                    paste("<font color=\"#008000\"><b>",
                          names(predictions[[i]]),
                          " ",
                          percent(predictions[[i]]),
                          "</b></font>")
                  )
                ),
                tags$p(input$list_description[i])
              )
            } else {
              tags$div(
                tags$h4(
                  tags$a(input$list_title[i],
                         href = input$list_url[i],
                         target="_blank")
                ),
                tags$p(
                  HTML(
                    paste("<font color=\"#008000\"><b>",
                          names(predictions[[i]]),
                          " ",
                          percent(predictions[[i]]),
                          "</b></font>")
                  )
                ),
                tags$p(input$list_description[i]),
                tags$hr()
              )
            }
          } else {
            if(i == length(input$list_title)) {
              tags$div(
                tags$h4(
                  tags$a(input$list_title[i],
                         href = input$list_url[i],
                         target="_blank")
                ),
                tags$p(
                  HTML(
                    paste("<font color=\"#FF0000\"><b>",
                          names(predictions[[i]]),
                          " ",
                          percent(predictions[[i]]),
                          "</b></font>")
                  )
                ),
                tags$p(input$list_description[i])
              )
            } else {
              tags$div(
                tags$h4(
                  tags$a(input$list_title[i],
                         href = input$list_url[i],
                         target="_blank")
                ),
                tags$p(
                  HTML(
                    paste("<font color=\"#FF0000\"><b>",
                          names(predictions[[i]]),
                          " ",
                          percent(predictions[[i]]),
                          "</b></font>")
                  )
                ),
                tags$p(input$list_description[i]),
                tags$hr()
              )
            }
          }
        })
      }
    })
    output$download <- downloadHandler(
      filename = function() {
        paste(format(Sys.time(), "%Y%m%d%H%M%S"), ".csv", sep = "")
      },
      content = function(file) {
        predictions <- predict_fasttext()
        downloadData <- data.frame("Title" = input$list_title,
                                   "URL" = input$list_url,
                                   "Description" = input$list_description,
                                   "Risk" = factor(sapply(predictions, names)))
        write.csv(downloadData, file, row.names = FALSE)
      }
    )
  }
)