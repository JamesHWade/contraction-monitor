library(shiny)
library(bslib)
library(bsicons)
library(tibble)
library(lubridate)
library(googlesheets4)
library(shinyWidgets)

url <- "https://docs.google.com/spreadsheets/d/1JB3beAR1wNaHEtP1hjadnyXgygG2BFtdxpqVrWMzy8o"
options(gargle_oauth_cache = ".secrets")
gs4_auth(cache = ".secrets", email = "james.wade1221@gmail.com")
contractions <- gs4_get(url)

# Uncomment to setup offline auth
# # Set authentication token to be stored in a folder called `.secrets`
# options(gargle_oauth_cache = ".secrets")
#
#
# # Authenticate manually
# gs4_auth()
#
# # If successful, the previous step stores a token file.
# # Check that a file has been created with:
# list.files(".secrets/")
#
# # Check that the non-interactive authentication works by first deauthorizing:
# gs4_deauth()
#
# # Authenticate using token. If no browser opens, the authentication works.
# gs4_auth(cache = ".secrets", email = "james.wade1221@gmail.com")

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  card(
    card_header("Contraction Severity", class = "bg-primary"),
    fluidRow(
      sliderInput("contraction",
                  "Severity of Contraction:",
                  min = 0,
                  max = 10,
                  value = 0,
                  width = "100%"),
      numericInput("duration",
                   "Duration of Contraction (in seconds):",
                   value = 0,
                   width = "100%")
    ),
    actionButton("save", "Save", icon = icon("save"), class = "btn-primary")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  observe({
    new_contraction <-
      tibble(
        Date     = now(tzone = "America/New_York"),
        Severity = input$contraction,
        Duration = input$duration
      )

    # try to append the new contraction to the sheet
    tryCatch({
      sheet_append(contractions, new_contraction)
      shinyWidgets::sendSweetAlert(
        title = "Success!",
        text = "Your contraction has been saved.",
        type = "success"
      )
    }, error = function(e) {
      shinyWidgets::sendSweetAlert(
        title = "Error!",
        text = "Your contraction could not be saved.",
        type = "error"
      )
    })
  }) |> bindEvent(input$save)
}

shinyApp(ui = ui, server = server)
