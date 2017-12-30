#load packages to run app
library(shiny)
library(shinythemes)
library(DT)
# setup ui of app
fluidPage(
  theme = shinytheme('simplex'),
  #title
  h2("Brad's Automated Checking Account Analyzer"),
  h5('Code for this app can be found', 
     a('here.', href = 'https://github.com/bgstieber/budget_shiny_app')),
  
  # add column for data upload
  fluidRow(
  column(2,
         h2('Upload Data'),
         fileInput('data_upload',
                   'Please upload a .csv file',
                   accept = c(
                     "text/csv",
                     "text/comma-separated-values,text/plain",
                     ".csv")
                   )
         ),
  
  column(10,
         navbarPage(
           "Summary Tabs",

           
           tabPanel('Data Viewer',
                    mainPanel(
                    dataTableOutput('budget_table')
                    )
                    ),
           
           tabPanel('Visual Trend Summaries',
                    mainPanel(
                      tabsetPanel(
                        tabPanel('Foo'),
                        tabPanel('Bar')
                      )
                    )
           ),          
           tabPanel('Numerical Trend Summaries',
                    mainPanel(
                      tabsetPanel(
                    tabPanel('Haz'),
                    tabPanel('Mat')
                   )
                    )
                   )
          
            )
         
         )
  )
)
