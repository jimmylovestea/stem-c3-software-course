# Load packages
library(shiny)

# Define UI for application
shinyUI(fluidPage(
  navbarPage(title = "Palmer Penguin Data Explorer",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("bins",
                             "Number of bins:",
                             min = 1,
                             max = 50,
                             value = 30)),
               mainPanel(
                 plotOutput("penguin_plot")))
             )
))