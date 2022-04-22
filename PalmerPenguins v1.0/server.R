# Load the packages needed by the server to run the app
library(shiny)
library(ggplot2)
library(palmerpenguins)

# Load the data
data(penguins)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$penguin_plot <- renderPlot({
    ggplot(data = penguins) +
      geom_histogram(aes(x = body_mass_g),
                     bins = input$bins) +
      theme_minimal() 
  })
})  