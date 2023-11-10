library(shiny)

ui <- fluidPage(
  titlePanel("This is the choice between the living and the dead"),
  tags$video(
    controls = T,
    src = "1.mp4",
    type = "video/mp4",
    width = "640",
    height = "360"
  )
)

options(shiny.maxRequestSize = 30*1024^2)
server <- function(input, output, session) {
  
}

shinyApp(ui, server)

# naman.a@u.nus.edu
