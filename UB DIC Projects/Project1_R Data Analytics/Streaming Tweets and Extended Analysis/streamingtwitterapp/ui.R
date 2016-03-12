library(shiny)

shinyUI(fluidPage(
  titlePanel("TWITTER ANALYSIS USING R SHINY"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Start Streaming !!!"),
      helpText("Enter search term"),
      textInput("searchterm", "Search Term", ""),
      #dateRangeInput("dates", 
      #               "Date range",
      #               start = "2016-01-01", 
      #               end = as.character(Sys.Date())),
      br(),
      actionButton("getdata",label="Get Data")
    ),
    mainPanel(
      h1(textOutput("text1")),
      tabsetPanel(
        #tabPanel("Plots", plotOutput("plot1")), 
        #tabPanel("Summary", verbatimTextOutput("summary")), 
        tabPanel("Streaming Data Plots",plotOutput("streamingplot3"), plotOutput("streamingplot1"), plotOutput("streamingplot2")),
        tabPanel("Election Data Analysis",tabsetPanel( 
            tabPanel("Map Tweets" ,plotOutput("trendplot4")),
            tabPanel("Tweet Nominee Trends" ,plotOutput("trendplot3")),
            tabPanel("Counts Per Day" ,plotOutput("trendplot2")),
            tabPanel("Summary", verbatimTextOutput("trendsummary"))
        )
            #tabPanel("Table",tableOutput("trendtable"))
          )
        )
      )
      #verbatimTextOutput("nText")
    )
  )
)
