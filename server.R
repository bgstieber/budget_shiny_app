library(shiny)
library(tidyverse)
shinyServer(function(input, output) {
  
  inFile <- reactive({input$data_upload})
  #reactive element for a file upload
  data.upload <- reactive({
    if(is.null(inFile())){
      NULL
    }else{
      read_csv(inFile()$datapath)
    }
  })
  
  budget_data_prep <- reactive({
    if(is.null(data.upload())){
      NULL
      }else{
        data.upload() %>%
          mutate(foo = 'bar bar')
      }
  }
  )
  
  output$budget_table <- renderDataTable(budget_data_prep())
}
)
