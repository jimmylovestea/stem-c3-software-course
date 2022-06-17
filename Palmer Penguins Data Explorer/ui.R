# Load packages needed to make things look pretty
library(knitr)
library(markdown)
library(shiny)
library(shinythemes)


# Define UI for application
shinyUI(fluidPage(
  
  # Use a "navbar" page with the "cerulean" theme.
  # Antarctica sounds cold so the theme seemed like a good fit.
  navbarPage(title = "Palmer Penguin Data Explorer",
             theme = shinytheme("cerulean"),
             
    # Render/load the "About" page which displays information which
    # tells the user what the app is about.
    tabPanel(title = "About",
                      
    # I wanted the "About" section to be written in an Rmd 
    # so that it's a bit easier to write. To get the Rmd to
    # render correctly though, I need the knit2html() function
    # which takes the Rmd, renders it to html BUT excludes the
    # header info so the theme will work.
              bootstrapPage(includeHTML(knit2html("about.Rmd", 
                                                  fragment = TRUE)))),
             
    # This is where the actual "app" part of the app lives. I want it in
    # its own 'tab', hence the tabPanel.
     tabPanel(title = "Palmer Penguins Data Explorer",
                      
    # Include a sidebar for users to choose options
    sidebarLayout(
      sidebarPanel(
                          
      # Choose histograms or scatter plots
      selectInput("plot_type",
      "Select a plot type:",
      choices = c("Histogram" = "hist",
                  "Scatter Plot" = "scatter"),
      selected = "hist"),
                          
      h4("Data Options"),
                          
      # Options for histogram
      conditionalPanel(
        condition = "input.plot_type == 'hist'",
        
        # Let user decide which species to look at
        checkboxGroupInput(inputId = "species", 
                           label = "Select species to plot:",
                           choices = c("Adelie" = "Adelie",
                                       "Chinstrap" = "Chinstrap",
                                       "Gentoo"= "Gentoo"),
                           selected = c("Adelie",
                                        "Chinstrap",
                                        "Gentoo")),
                            
        # Let users select one of the measurements
        selectInput("measurement", 
                    "Select a measurement:",
                    choices = c("Body mass"= "body_mass_g",
                                "Bill length" = "bill_length_mm",
                                "Bill depth" = "bill_depth_mm",
                                "Flipper length" = "flipper_length_mm"),
                    selected = "Body mass"),
                            
        # Allow users to facet by categorical variables
        radioButtons("facets",
                      "Facet plot by:",
                      choices = c("Nothing" = "none",
                                  "Species" = "species",
                                  "Sex" = "sex",
                                  "Island" = "island"),
                      selected = "none"),
                            
        # If user facets by "sex", show a conditional panel to drop NA vals
        conditionalPanel(
          condition = "input.facets == 'sex'",
          checkboxInput("drop_na_sex",
                        label = "Drop NA values?")),
                            
        h4("Plot Customizations"),
                            
        # This is where users can customize their histograms
        sliderInput("bins",
                    "Number of bins:",
                    min = 1,
                    max = 50,
                    value = 30),
                            
        # And this is where users can choose a color
        textInput("color",
                  "Color of bins:",
                  value = "steelblue"),
                            
        # Allow users to "fix" the x-axis
        radioButtons("axes",
                      "Floating or Fixed axes?",
                      choices = c("Floating" = "float",
                                  "Fixed" = "fixed"),
                      selected = "float")),
                          
                          
        # Options for scatterplot
        conditionalPanel(
          condition = "input.plot_type == 'scatter'",
          # Let user decide two variables to look at
          
          # Var 1
          selectInput("var_1", 
                      "Select measurement for the x-axis:",
                      choices = c("Body mass"= "body_mass_g",
                                  "Bill length" = "bill_length_mm",
                                  "Bill depth" = "bill_depth_mm",
                                  "Flipper length" = "flipper_length_mm"),
                      selected = "body_mass_g"),
                            
          # Var 2
          selectInput("var_2", 
          "Select measurement for the y-axis:",
          choices = c("Body mass"= "body_mass_g",
                      "Bill length" = "bill_length_mm",
                      "Bill depth" = "bill_depth_mm",
                      "Flipper length" = "flipper_length_mm"),
          selected = "bill_length_mm"),
                            
          # Let users choose colors base on a variable
          radioButtons("colors",
                        "Color points based on:",
                        choices = c("Nothing" = "NULL",
                                    "Species" = "species",
                                    "Sex" = "sex",
                                    "Island" = "island"),
                        selected = "NULL")
          ),
      ),
                        
      # Let the outputs show up here in the main panel    
      mainPanel(
        
        # Show the plot
        plotOutput("penguin_plot"),
        
        # Include numerical summaries
        verbatimTextOutput("penguin_summaries"),
        
        # Add directions for something like an assignment
        h3("Student Task Directions"),
        p("Using the app, answer some questions"),
        p("1. Describe the center, shape, and spread of all the Palmer Penguins."),
        p("2. ... more questions go here...")
        )
      )
    )
  )
))
