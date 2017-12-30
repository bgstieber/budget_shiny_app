library(shiny)
library(tidyverse)
library(anytime)

clean_data <- function(data){
  
  names(data) <- tolower(data)
  
  data %>%
    mutate(data = anydate(date)) %>%
    mutate(credit_or_debit = ifelse(transaction >= 0,
                                    'credit',
                                    'debit'),
           first_of_month = format(date, '%Y-%m-01'))
  
}

running_total_by_date <- function(data){
  data %>%
    group_by(date) %>%
    summarise(sum_transaction = sum(transaction)) %>%
    ungroup() %>%
    arrange(date) %>%
    mutate(running_total = cumsum(sum_transaction))
}

credit_debit_trend <- function(data){
  data %>%
    group_by(first_of_month,
             credit_or_debit) %>%
    summarise(sum_transaction = sum(abs(transaction)))
}

shinyServer(function(input, output) {
  inFile <- reactive({
    input$data_upload
  })
  #reactive element for a file upload
  data.upload <- reactive({
    if (is.null(inFile())) {
      NULL
    } else{
      read_csv(inFile()$datapath)
    }
  })
  
  budget_data_prep <- reactive({
    if (is.null(data.upload())) {
      NULL
    } else{
      data.upload() %>%
        mutate(foo = 'bar bar')
    }
  })
  
  output$budget_table <- renderDataTable(budget_data_prep())
  
  output$growth_rate_table <- renderTable(data.frame(
    'growth_3' = 10,
    'growth_6' = 12,
    'growth_12' = 16
  ))
  
  output$growth_rate_plot <- renderPlot(plot(1:10))
  
})

