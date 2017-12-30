#load packages to run app
library(shiny)
library(shinythemes)
library(DT)
# setup ui of app
fluidPage(
  theme = shinytheme('flatly'),
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
    
    radioButtons('date_format',
                 'How is your date formatted?',
                 choices = c('YYYY-MM-DD' = '%Y-%m-%d',
                             'MM/DD/YYYY' = '%m/%d/%Y',
                             'DD/MM/YYYY' = '%d/%m/%Y',
                             'DD-MM-YYYY' = '%d-%m-%Y',
                             'Other' = 'other')
                 ),
    
    conditionalPanel("input.date_format == 'other'",
                     h5(strong('By specifying "Other", we will use
                               the anydate function from the anytime
                               package to attempt to coerce the date.'))),
    
    br(),
    
    p("Your .csv file must contain at least two columns: one column named “date” 
      (case insensitive) which is consistently formatted in a manner which is 
      recognizable as a date (e.g. 01/01/2015, 2015-01-01, 01-01-2015, etc.) 
      and another column named “transaction” (case insensitive) that has 
      numerical values for credits and debits. Transactions which are credits 
      should be expressed as positive values, and debits should be expressed as 
      negative values."),
    br(),
    p("We will attempt to perform some minimal processing on the transaction 
      and date columns. Namely, we’ll attempt to remove any commas in the 
      transaction column prior to coercing it to numeric, and we’ll attempt 
      to coerce the date column using the format you've selected."),
    br(),
    p("By coercing the date column to a date-type and coercing the transaction
      column to numeric, we run the risk of improper coercion, resulting in NA
      values. Use the Data Viewer tab to determine if you need to re-format 
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
                            plotOutput('running_balance_plot',
                                       height = "600px")),
                   tabPanel('Debits / Credits Trend',
                            plotOutput('debit_credit_trend',
                                       height = "600px")),
                   tabPanel(
                     'Ending Monthly Balance',
                     plotOutput('ending_monthly_bal_plot',
                                height = "600px")
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
                     plotOutput('growth_rate_plot',
                                height = "600px")
                   )
                 )
               ))
      
    )
    
  ))
)
