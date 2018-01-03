# App Description

The app is live! [Go check it out!](https://bgstieber.shinyapps.io/budget_shiny_app/)

# Main Description

Every few weeks or so I do a fairly rudimentary analysis of my personal finances, mainly investigating the balance of my checking account. The typical analysis will look something like:

  1. Read in data
  1. Clean it up a bit
  1. Summarize (visually) in a few different ways
      - Trend in balance
      - Trend in debits / credits
      - Monthly totals
  1. Summarise (numerically) in a few different ways
      - How much have I saved in the last few months
      - How much has my balance grown in the last few months
      - If my savings trends were to continue, how much could I expect to have in 3, 6, or 12 months
        - This requires the fitting of some form of a regression model (a simple linear model seems to do just fine)
      
By now, this analysis has become rather routine, and follows a fairly structured flow. To save myself time (and to re-familiarize myself with git and Shiny), I decided building an automated system might be "fun". 

# More about the app

(as I continue to develop the app, this section will become more detailed)

## Tabs

  - __Data Upload and Viewer__
    - Allow the user to upload a two column csv (date and amount)
      - Dates are hard (necessary to experiment with `anytime::anydate`)
        - Give user a toggle to control how dates were entered?
      - Amounts are hard too
        - Exhell formatting (commas, parentheses)
    - Display the data to the user
      - use `DT::datatable` to provide some interactivity
  - __Trend Visualizer__
    - Running sum of balance by date
      - Simple time series plot
    - Trend in debits / credits
      - Two column (one for debits, one for credits) dodged bar plot by month
    - Ending monthly balance
      - Bar chart
  - __Numerical Summaries__
    - Table with monthly summaries
      - Credits, debits, total, saving rate, running total, 6 month % change in running total
    - Expected growth rate
      - We use the exceptional [__`prophet`__](https://github.com/facebook/prophet) package to build a time series forecast.
      