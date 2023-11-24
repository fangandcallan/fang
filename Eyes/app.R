library(shiny)
library(shinyjs)

# Shiny UI
ui <- fluidPage(
  shinyjs::useShinyjs(),
  titlePanel("This is the choice between the living and the dead"), 
  tags$iframe(
    id = "videoPlayer",
    src = "https://www.youtube.com/embed/Rrb5ElwwSh0?autoplay=1",
    width = "640",
    height = "360"
  ),
  sidebarLayout(
    sidebarPanel(
      h3("Select Eyes:"),
      radioButtons("eyeColor", "",
                   choices = c("Brown eyes", "Blue eyes", "Green eyes")
      ),
    ),
    mainPanel(
      h3("Last Statement:"),
      textOutput("lastStatement"),
      br(),
      actionButton("closeEyes", "Close their eyes"),
      actionButton("burnBody", "Condemn their body by burning them"),
      textOutput("choiceMessage")
    )
  )
)

# Shiny Server
server <- function(input, output, session) {
  merged_data <- read.csv("merged_data.csv")
  
  output$lastStatement <- renderText({
    eye_color <- switch(input$eyeColor,
                        "Brown eyes" = "Brown",
                        "Blue eyes" = "Blue",
                        "Green eyes" = "Green"
    )
    
    if (eye_color == "") {
      last_statements <- merged_data$Last.Statement[is.na(merged_data$EyeColor)]
    } else {
      last_statements <- merged_data$Last.Statement[merged_data$EyeColor == eye_color]
    }
    
    if (length(last_statements) == 0) {
      return("This person has left no words.")
    }
    
    random_statement <- sample(last_statements, 1)
    random_statement
  })
  
  closeEyesCount <- reactiveVal(0)
  burnBodyCount <- reactiveVal(0)
  
  currentVideo <- reactiveVal("https://www.youtube.com/embed/Rrb5ElwwSh0?autoplay=1")
  
  observe({
    # Attempt to trigger autoplay for the initial video
    shinyjs::runjs("document.getElementById('videoPlayer').contentWindow.postMessage({event: 'command', func: 'mute', args: []}, '*');");
  })
  
  observeEvent(input$closeEyes, {
    closeEyesCount(closeEyesCount() + 1)
    
    if (closeEyesCount() == 3 | closeEyesCount() == 5) {
      if (closeEyesCount() == 3){
        videoUrlcloseeyes <- "https://www.youtube.com/embed/ngcgrYjuf5U?autoplay=1"
      } else {
        videoUrlcloseeyes <- "https://www.youtube.com/embed/ScGNAsh9DMg?autoplay=1"
      }
      currentVideo(videoUrlcloseeyes)
    }
  })
  
  observeEvent(input$burnBody, {
    burnBodyCount(burnBodyCount() + 1)
    
    if (burnBodyCount() == 3 | burnBodyCount() == 5) {
      if (burnBodyCount() == 3){
        videoUrlburnbody <- "https://www.youtube.com/embed/iBvlNIYJkAo?autoplay=1"
      } else {
        videoUrlburnbody <- "https://www.youtube.com/embed/fPudGbjwzTE?autoplay=1"
      }
      currentVideo(videoUrlburnbody)
    }
  })
  
  observe({
    shinyjs::runjs(paste0("document.getElementById('videoPlayer').src = '", currentVideo(), "';"))
  })
  
  choiceMessage <- reactive({
    validate(need(!is.null(burnBodyCount()) && !is.null(closeEyesCount()), "Counts not initialized"))
    
    if (burnBodyCount() >= 5 || closeEyesCount() >= 5) {
      return("You've made a choice. Live on with hope.")
    } else {
      return(NULL)
    }
  })
  
  output$choiceMessage <- renderText({
    choiceMessage()
  })
  
  onStop(function() {
    if (!is.null(choiceMessage())) {
      print(choiceMessage())
    }
  })
}

shinyApp(ui, server)
