library(shiny)
library(tidyverse)
library(anytime)
library(scales)
theme_set(theme_bw())

clean_data <- function(data, date_format) {
  names(data) <- tolower(names(data))
  if (date_format == 'other') {
    data2 <- data %>%
      mutate(date = anydate(date))
  } else{
    data2 <- data %>%
      mutate(date = as.Date(date,
                            format = date_format))
  }
  
  data2 %>%
    mutate(transaction = as.numeric(gsub(
      pattern = ",",
      replacement = "",
      x = transaction
    ))) %>%
    mutate(
      credit_or_debit = ifelse(transaction >= 0,
                               'credit',
                               'debit'),
      first_of_month = as.Date(format(date, '%Y-%m-01'))
    )
  
}

running_total_by_date <- function(data) {
  data %>%
    group_by(date) %>%
    summarise(sum_transaction = sum(transaction)) %>%
    ungroup() %>%
    arrange(date) %>%
    mutate(running_total = cumsum(sum_transaction))
}

running_total_plot <- function(data) {
  data %>%
    ggplot(., aes(x = date, y = running_total)) +
    geom_line(stat = 'smooth',
              method = 'loess',
              alpha = 0.5,
              colour = '#b70101')+
    geom_line(colour = 'dodgerblue3',
              size = 1.2) +
    xlab('Date') +
    scale_y_continuous(labels = dollar,
                       name = 'Running Balance')
}

credit_debit_trend <- function(data) {
  data %>%
    group_by(first_of_month,
             credit_or_debit) %>%
    summarise(sum_transaction = sum(abs(transaction)))
}

credit_debit_plot <- function(data) {
  data %>%
    ggplot(.,
           aes(x = first_of_month,
               y = sum_transaction,
               colour = credit_or_debit)) +
    geom_line() +
    geom_point() +
    scale_colour_brewer(palette = 'Set1',
                        name = 'Transaction Type') +
    scale_y_continuous(labels = dollar,
                       name = 'Monthly Total') +
    xlab('Date')
  
}

monthly_difference <- function(data) {
  data %>%
    group_by(first_of_month) %>%
    summarise(
      sum_transaction = sum(transaction),
      sum_credits = sum(ifelse(
        credit_or_debit == 'credit',
        transaction,
        0
      )),
      sum_debits = sum(ifelse(
        credit_or_debit != 'credit',
        transaction,
        0
      ))
    ) %>%
    ungroup() %>%
    arrange(first_of_month) %>%
    mutate(
      cum_sum_transaction = cumsum(sum_transaction),
      saving_rate = (sum_transaction / sum_credits)
    ) %>%
    select(
      first_of_month,
      sum_credits,
      sum_debits,
      sum_transaction,
      saving_rate,
      cum_sum_transaction
    )
}

monthly_end_plot <- function(data) {
  p1 <- data %>%
    ggplot(., aes(x = first_of_month,
                  y = sum_transaction)) +
    geom_col() +
    scale_y_continuous(labels = dollar,
                       name = 'Credits - Debits') +
    xlab('Date')
  
  p2 <- data %>%
    ggplot(., aes(x = first_of_month,
                  y = cum_sum_transaction)) +
    geom_line() +
    geom_point() +
    scale_y_continuous(labels = dollar,
                       name = 'Monthly Running Total') +
    xlab('Month')
  
  gridExtra::grid.arrange(p1, p2, ncol = 1)
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
        clean_data(input$date_format)
    }
  })
  
  output$budget_table <- renderDataTable(budget_data_prep())
  
  output$running_balance_plot <- renderPlot(budget_data_prep() %>%
                                              running_total_by_date() %>%
                                              running_total_plot())
  
  output$debit_credit_trend <- renderPlot(budget_data_prep() %>%
                                            credit_debit_trend() %>%
                                            credit_debit_plot())
  
  output$ending_monthly_bal_plot <- renderPlot(budget_data_prep() %>%
                                                 monthly_difference() %>%
                                                 monthly_end_plot())
  
  output$monthly_summary_table <- renderDataTable(
    budget_data_prep() %>%
      monthly_difference() %>%
      arrange(first_of_month) %>%
      mutate(
        six_month_change =
          (cum_sum_transaction - lag(cum_sum_transaction, 6)) /
          cum_sum_transaction,
        twelve_month_change =
          (cum_sum_transaction - lag(cum_sum_transaction, 12)) /
          cum_sum_transaction
      ) %>%
      arrange(desc(first_of_month)) %>%
      datatable(
        .,
        rownames = FALSE,
        colnames = c(
          'Month',
          'Credits',
          'Debits',
          'Credits-Debits',
          'Saving Rate',
          'Running Sum',
          '6 Month % Change',
          '12 Month % Change'
        )
      ) %>%
      formatCurrency(
        .,
        columns = c(
          'sum_credits',
          'sum_debits',
          'sum_transaction',
          'cum_sum_transaction'
        )
      ) %>%
      formatPercentage(
        .,
        columns = c('saving_rate',
                    'six_month_change',
                    'twelve_month_change'),
        digits = 1
      )
  )
  
  output$growth_rate_table <- renderTable(data.frame(
    'growth_3' = 10,
    'growth_6' = 12,
    'growth_12' = 16
  ))
  
  output$growth_rate_plot <- renderPlot(plot(1:10))
  
})
