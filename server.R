# change the 120 to a larger number if you are doing a humongous file lol 
options(shiny.maxRequestSize=120*1024^2) 

library(shiny)
library(ggplot2)
library(dplyr)
library(readxl)
library(ggthemes)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  df <- eventReactive(input$submit, {
    
    # reads a database of  name | size | type | filepath
    inFile <- input$pfeimputed
  
    # reads the uploaded file, excel or csv are both ok. 
    if(grepl("xlsx",inFile[1,1]) == TRUE){ 
      thedata <- read_xlsx(inFile[1,4])
      }
    else thedata <- read.csv(inFile[1,4], stringsAsFactors = FALSE)
    
    # select the columns to be plotted and create a table of hiin_abbr | Time | total_pfe  
    thedata <- subset(x = thedata, select = c("hiin_abbr","total_pfe","Time"))
    thedata <- group_by(thedata, hiin_abbr, Time, add = TRUE)
    thedata <- summarise_all(thedata, mean)
    
    # copied code from old script - this just refactors the data so that the legend is in order of 
    # total_pfe at the final time. 
    time. <- thedata$Time
    HIIN_y <- thedata[thedata$Time == max(time.),]
    re.order <- HIIN_y$hiin_abbr[order(HIIN_y$total_pfe,
    decreasing = TRUE)]
    re.order <- na.omit(re.order)
    thedata$hiin_abbr <- factor(thedata$hiin_abbr,
                                levels = re.order)
    
  # df() is now the reactive call to thedata  - note, for facilities that START as NA values, they are excluded until 
  # they submit a value 
    na.omit(thedata)


  })
  output$pfeplot <- renderPlot({
    print(gfplot()) }) # higher resolution, default is 72)
  
  gfplot <- reactive({
    # take the input values for the time axis and titling 
    breaks <- as.numeric(unlist(strsplit(input$timebreaks,",")))
    labels <- trimws(unlist(strsplit(input$timelabels,",")))
    beginning <- labels[1]
    
    # 16 colors colorblind friendly, randomized, hard (Force Vector) from tools.medialab.sciences-po.fr/iwanthue/ 
    the.colors <- c("#92004a",
                    "#31e48d",
                    "#b53aa7",
                    "#33a235",
                    "#ff92ff",
                    "#005f12",
                    "#0049b7",
                    "#d3db74",
                    "#680051",
                    "#019d6d",
                    "#ad0028",
                    "#005c9b",
                    "#8a7800",
                    "#75447f",
                    "#675200",
                    "#ff7061")
    
    # develop the plot 
    g <- ggplot(data = df(),
                aes(x = Time, y = total_pfe, color = hiin_abbr))
    g <- g + scale_color_manual(values = the.colors)
    
    # add lines 
    gg <- g + geom_smooth(method = "loess", se = FALSE)
    
    # add labels 
    ggg <- gg + labs(title = "", 
                     y = "Average Total Metrics",
                     x = "") 
    
    
    
    gf <- ggg + labs(color = "HIINs")
    gf <- gf + labs(title = paste0("Metrics Implemented, by HIIN: Trends Since ", labels[1]),
                    subtitle = paste0("HIINs ordered by performance as of ", labels[length(labels)])
                    )
    
    
    #print plot
    
    #  they requested we remove style =  "darkunica"  
     gf <- gf + theme_hc(style = "default") + 
      theme(legend.position = "right") + 
      ylim(c(0,5)) + 
      theme(plot.title = element_text(hjust = 0.5)) + scale_x_continuous(breaks = breaks,
                                                                         labels = labels) 
 
   gf
   
   })
    
 
  
  output$loess <- downloadHandler(
    filename =  "loess.png",
    content = function(file){ 
      ggsave(file, plot = gfplot(), device = "pdf", width = 8, height = 8, units = "in", dpi = 75)
      }
  )
  
})
  
  
  
