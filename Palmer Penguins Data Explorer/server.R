# Load the packages needed by the server to run the app
library(shiny)
library(palmerpenguins)
library(dplyr)
library(ggplot2)

# Load the data
data(penguins)

# Define server logic
shinyServer(function(input, output) {
  
  # Format data based on species selection
  # Make this "reactive" so it updates based on user selection
  plot_data <- reactive({
    
    # For the histograms, allow users to subset their data based
    # on desired species.
    # I use an if() statement to avoid changing the data when
    # a scatterplot is selected
    if (input$plot_type == "hist") {
      
      # Take the penguins data and filter by specied selected
      penguins %>% 
        filter(species %in% input$species)
    } else {
      # For scatterplots, just use all the data
      penguins
    }
  })
  
  # Create a plot based on user selections
  output$penguin_plot <- renderPlot({

# Design note: Would be great to color the bars based on a 
# categorical variable in the future.
    
    # For histograms...
    if (input$plot_type == "hist") {
      
      # Create a "basic" plot to start with
      p <- ggplot(data = plot_data()) +
        
        # Draw a histogram based on the measurement selected
        geom_histogram(aes_string(x = input$measurement),
                       
                       # Change the color if needed based on 
                       # user selection
                       fill = input$color,
                       
                       # This will make the outline "white"
                       color = "white",
                       
                       # change the number of bins based on
                       # user selection
                       bins = as.numeric(input$bins)) +
        theme_minimal() 
      
      # "Fix" the x-axis if the user selected that option 
      if (input$axes == "fixed") {
        
        # This takes the original plot and "re-saves" is with a set
        # of limits for the x-axis based on _all_ of the data for each 
        # measurement (Flipper size, body mass, etc).
        
        # Note: There's NAs in the values so we need to remove them with
        # na.rm = TRUE
        p <- p + xlim(range(penguins[[input$measurement]], na.rm = TRUE))
      } 
      
      # Let the user "facet" the plot
      if (input$facets != "none") {
        
        # If they DO want to facet, "re-save" the plot but with facets.
        # But first, see if they want to (1) facet by 'sex' and (2) drop
        # the NA values from sex.
        if (input$facets == "sex" & input$drop_na_sex) {
          
          # Below, the `%+%` operator lets us take the data from the plot "p"
          # and update it according to some logic. 
          # In this case, I want to take my plot_data() and find which values
          # for sex are not (!) NA.
          p <- p %+% filter(plot_data(), !is.na(sex)) + 
                     facet_wrap(input$facets, ncol = 1)
        } else {
          
          # Otherwise, just facet the plot as usual
          p <- p + facet_wrap(input$facets, ncol = 1)
        }
      }
    }
    
    # For scatterplots ...
    if (input$plot_type == "scatter") {
      
      # Create a basic scatter plot
      p <- ggplot(data = plot_data()) +
        geom_point(aes_string(x = input$var_1,
                              y = input$var_2,
                              color = input$colors)) +
        theme_minimal() +
        theme(legend.position = "bottom")
    }
    p
  })
  
  # Add summary statistics to the main panel
  output$penguin_summaries <- renderPrint({
    
    # If the plot type is a histogram, then...
    if (input$plot_type == "hist") {
      
      # Compute numerical summaries of the selected variable
      pen_summary <- summary(penguins[[input$measurement]])
    } 
    
    # If the plot type is a scatterplot
    if (input$plot_type == "scatter") {
      
      # Create a table of summary statistics
      
# Design Note: This is sort of "hacky", would be great if I could
# clean this code up in the future.
      
      # Create an empty data frame to hold values
      pen_summary <- data.frame(matrix(NA, nrow = 2, ncol = 7),
                                row.names = c(input$var_1, input$var_2))
      
      # Assign names to the data frame
      names(pen_summary) <- c("Min.", "1st Qu.", "Median", 
                              "Mean", "3rd Qu.", "Max.", "NA's")
      
      # Populate the data frame 
      pen_summary[1, ] <- as.numeric(summary(penguins[[input$var_1]]))
      pen_summary[2, ] <- as.numeric(summary(penguins[[input$var_2]]))
    }
    pen_summary
  })
})
