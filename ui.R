
library(shiny)

# Define UI for application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Create Loess Smoothed Plot"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
      h4("Be careful with HRET showing up as the HIIN Abbr. Those should be completely inside AHA. 
         Fix anything with the excel file before uploading here. This app uses the output from the PFE Impute app.
         Excel or CSV file format is acceptable (i.e. .csv  or  .xlsx"),
       fileInput(inputId = "pfeimputed", label = "Upload The Imputed Data File",
                 multiple = FALSE,
                 accept = c(".csv",".xlsx"),
                 buttonLabel = "Browse"), 
      textInput(inputId = "timebreaks", label = "Where to Label X Axis", value = "1,5"),
      textAreaInput(inputId = "timelabels", label = "What to Label X Axis", value = c("Sept 2017, Jan 2018")),
       actionButton(inputId = "submit", label = "Make Plot"),
       downloadButton("loess", label = "Download Plot")
    ),
    
    # Show a plot 
    mainPanel(
      h4("Note: the Time axis is numeric, 1 is the first month of the data imputed. Make sure to set the Time labels accordingly!"),
       plotOutput("pfeplot")
    )
  )
))
