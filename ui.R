#load packages to run app
library(shiny)
library(shinythemes)
library(DT)
# setup ui of app
fluidPage(
  theme = shinytheme('flatly'),
  p('This blah blah blah'),
  h5(
    'Code for this app can be found',
    a('here.', href = 'https://github.com/bgstieber/budget_shiny_app')
  ),
  
  # add column for data upload
  fluidRow(column(
    2,
    h2('Upload Data'),
    fileInput(
      'data_upload',
      'Please upload a .csv file',
      accept = c("text/csv",
                 "text/comma-separated-values,text/plain",
                 ".csv")
    ),
    p("You .csv file must contain at least two columns: one column named “date” 
      (case insensitive) which is consistently formatted in a manner which is 
      recognizable as a date (e.g. 01/01/2015, 2015-01-01, 01-01-2015, etc.) 
      and another column named “transaction” (case insensitive) that has 
      numerical values for credits and debits. Transactions which are credits 
      should be expressed as positive values, and debits should be expressed as 
      negative values."),
    br(),
    p("We will attempt to perform some minimal processing on the transaction 
      and date columns. Namely, we’ll attempt to remove any commas in the 
      transaction column, and we’ll attempt to convert the date column using 
      the `anydate` function from the `anytime` package. 
      Use the Data Viewer tab to determine if you need to re-format 
      either the transaction or date columns.")
  ),
  
  column(
    10,
    navbarPage(
      "Summary Tabs",
      
      tabPanel('Data Viewer',
               mainPanel(dataTableOutput('budget_table'))),
      
      tabPanel('Visual Trend Summaries',
               mainPanel(
                 tabsetPanel(
                   tabPanel('Running Balance by Date',
                            plotOutput('running_balance_plot')),
                   tabPanel('Debits / Credits Trend',
                            plotOutput('debit_credit_trend')),
                   tabPanel(
                     'Ending Monthly Balance',
                     plotOutput('ending_monthly_bal_plot')
                   )
                 )
               )),
      tabPanel('Numerical Trend Summaries',
               mainPanel(
                 tabsetPanel(
                   tabPanel('Saving by Month',
                            dataTableOutput('saving_by_month')),
                   tabPanel(
                     'Ending Monthly Balance',
                     dataTableOutput('ending_monthly_bal_table')
                   ),
                   tabPanel(
                     'Expected Balance Growth Rate',
                     tableOutput('growth_rate_table'),
                     plotOutput('growth_rate_plot')
                   )
                 )
               ))
      
    )
    
  ))
)
