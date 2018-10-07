# Globální init



# generic Ilford datasheet
Ilford <- tibble(measured = c(1,2,4,8,15,20,25,30),
                 adjusted = c(1,4,9,24,55,82,118,155))


ChrtSrc <- Ilford # data frame for analysis


makeReactiveBinding("ChrtSrc") # jsem reaktivní!!!
makeReactiveBinding("times") # jsem reaktivní!!!

times <- NA # data frame for export


# helper functions

CastData <- function(data) {
  datar <- data.frame(measured = as.numeric(data["measured"]),
                      adjusted = as.numeric(data["adjusted"]),
                      stringsAsFactors = F)
  return (datar)
}

CreateDefaultRecord <- function() {
  mydefault <- CastData(list(measured = 1, 
                             adjusted = 1))
  return (mydefault)
}


UpdateInputs <- function(data, session) {
  updateTextInput(session, "measured", value = unname(data["measured"]))
  updateTextInput(session, "adjusted", value = unname(data["adjusted"]))
}

# CRUD methods:
CreateData <- function(data) {
  
  data <- CastData(data)

  if (exists("ChrtSrc")) {
    ChrtSrc <<- rbind(ChrtSrc, data)
  } else {
    ChrtSrc <<- data
  }
  ChrtSrc <<- arrange(ChrtSrc, measured)
}


ReadData <- function() {
  if (exists("ChrtSrc")) {
    return(ChrtSrc[ , 1:2]) # first two columns only = bez labelu
  }
}

UpdateData <- function(data) {
  data <- CastData(data)
  data$label <- paste(data$measured, '/', data$adjusted)
  
  ChrtSrc <<- rbind(ChrtSrc, data) %>%
    arrange(measured)
}


DeleteData <- function(data) {
  asdf <- ChrtSrc$measured != data[1] | ChrtSrc$adjusted != data[2]
  ChrtSrc <<- ChrtSrc[asdf, ] 
}


GetTableMetadata <- function() {
  fields <- c(measured = "Measured Time", 
              adjusted = "Adjusted Time")
  
  result <- list(fields = fields)
  return (result)
}