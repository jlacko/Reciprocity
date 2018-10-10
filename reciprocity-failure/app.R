# Shiny app na regresi švára efektu pro různé filmy


library(shiny)
library(ggplot2)
library(dplyr)

# globální init
source('common-code.R')


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Model of Film Reciprocity Failure / Schwarzschild Effect"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        
        #data table
        DT::dataTableOutput("table"), 
        
        #input fields
        tags$hr(),
        textInput("make", "Film Make", "Generic Ilford Film"),
        textInput("measured", "Measured time", "1"),
        textInput("adjusted", "Adjusted time", "1"),
      

        #action buttons
        tags$hr(),
        actionLink("new", "Reset"), code('/'),
        actionLink("submit", "Insert Row"), code('/'),
        actionLink("delete", "Delete Row")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("regPlot",  height = "600px"),
         h4("Standard exposure times (in ½ stop intervals)"),
         tableOutput("modelled"),
         downloadLink("getData", label = "Save table as CSV file")
      )
   )
)

# Define server logic
server <- function(input, output, session) {
   
   output$regPlot <- renderPlot({
     
      ChrtSrc <<-  mutate(ChrtSrc, label = paste(measured, '/', adjusted))
      
      # run the regression based on log log transformation
      expmodel <- lm(formula = log(adjusted) ~ log(measured), data = ChrtSrc)
      
      # calculate source data for chart based on regression formula
      model <- tibble(measured = c(1:120), 
                      modelled = exp(coef(expmodel)[1])*measured^coef(expmodel)[2])
      
      # calculate standard exposure times (in 1/2 stop incrementes)
      times <<- tibble(measured = c(1,1.41,2,3,4,6,8,11,16,23,32,45,64,90,128,180),
                      adjusted = round(exp(coef(expmodel)[1])*measured^coef(expmodel)[2], 0))
      
      
      # draw the chart
      ggplot() +
        geom_point(data = ChrtSrc, aes(x = measured, y = adjusted),color = "darkorange2", shape = 20, size = 2) +
        geom_text(data = ChrtSrc, aes(x = measured, y = adjusted, label = label), size = 3, vjust = -1) +
        geom_line(data = model, aes(x = measured, y = modelled), color = "cornflowerblue", linetype = "dotdash") +
        scale_x_continuous(breaks = c(1,2,4,8,15,30,60,120),
                           limits = c(1, 63)) +
        scale_y_continuous(breaks = c(15,30,60,120,180,5*60,7*60,10*60,15*60),
                           limits = c(1, model$modelled[63])) +
        theme_classic() +
        theme(plot.title = element_text(size = rel (1.5), face = "bold"))+
        labs(x = "measured time (sec.)", y = "adjusted time (sec)", 
             title = "Reciprocity failure",
             subtitle = input$make)
   })
   


   # Click "Submit" button -> save data
   observeEvent(input$submit, {
     if (input$measured != "" & input$adjusted != '') {
       UpdateData(list(measured = input$measured, 
                       adjusted = input$adjusted))
     }
   })
   
   # Press "New" button -> display empty record
   observeEvent(input$new, {
     UpdateInputs(CreateDefaultRecord(), session)
   })
   
   # Press "Delete" button -> delete from data
   observeEvent(input$delete, {
     DeleteData(list(measured = input$measured, 
                     adjusted = input$adjusted))
     UpdateInputs(CreateDefaultRecord(), session)
   })
   
   # Select row in table -> show details in inputs
   observeEvent(input$table_rows_selected, {
     if (length(input$table_rows_selected) > 0) {
       data <- ReadData()[input$table_rows_selected, ]
       UpdateInputs(data, session)
     }
     
   })
   
   # pres download data -> initiate save csv
   output$getData <- downloadHandler(
     
     filename = "model.csv",
     content = function(file) write.csv2(times, file, row.names = F),
     contentType = "text/csv"
     
   )
   
   # display table measured & adjusted
   output$table <- DT::renderDataTable({
   ReadData()
   }, server = F, selection = "single",
   colnames = c("Measured", "Adjusted"),
   rownames = F,
   options = list(dom = 't') # as simple as they get = no search, no filter, no pages
  )
  

   # display table modelled
   output$modelled <- renderTable({
     
     as.data.frame(t(times[-2, ]))
     
   }, digits = 0, colnames = F, width = "50%")
    
}

# Run the application 
shinyApp(ui = ui, server = server)

