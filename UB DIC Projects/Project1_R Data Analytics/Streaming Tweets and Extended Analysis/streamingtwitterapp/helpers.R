library(streamR)
library(twitteR)
library(ROAuth)
library(jsonlite)
library(devtools)


loadAuth <- function() {
    if(file.exists("F:/Projects/streamingtwitterapp/my_oauth.Rdata"))
    {
      #oauth_file<-file.path("F:/Projects/streamingtwitterapp",  "my_oauth.Rdata") 
      load("F:/Projects/streamingtwitterapp/my_oauth.Rdata")
    }
    else
    {
        cat("my_oauth doesnt exist... creating")
        install_github("streamR", "pablobarbera", subdir = "streamR")
        requestURL <- "https://api.twitter.com/oauth/request_token"
        accessURL <- "https://api.twitter.com/oauth/access_token"
        authURL <- "https://api.twitter.com/oauth/authorize"
        consumerKey <- "ax4TCkpNczz2gGZCQPzlTieZ1"
        consumerSecret <- "t6anJn4xZHfkNGubGDqh5CrWUJW9pXT9rqNvTd1Rao0twux6pg"
        my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                                     requestURL = requestURL, accessURL = accessURL, authURL = authURL)
        my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))+
        save(my_oauth, file = "my_oauth.Rdata")
        load("F:/Projects/streamingtwitterapp/my_oauth.Rdata")
    }
  }


# clean text function
clean.text <- function(some_txt)
{  some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
some_txt = gsub("@\\w+", "", some_txt)
some_txt = gsub("[[:punct:]]", "", some_txt)
some_txt = gsub("[[:digit:]]", "", some_txt)
some_txt = gsub("http\\w+", "", some_txt)
some_txt = gsub("[ \t]{2,}", "", some_txt)
some_txt = gsub("^\\s+|\\s+$", "", some_txt)
# Remove non-english characters
some_txt = gsub("[^\x20-\x7E]", "", some_txt)

# define "tolower error handling" function
try.tolower = function(x)
{  y = NA
try_error = tryCatch(tolower(x), error=function(e) e)
if (!inherits(try_error, "error"))
  y = tolower(x)
return(y)
}

some_txt = sapply(some_txt, try.tolower)
some_txt = some_txt[some_txt != ""]
names(some_txt) = NULL
return(some_txt)
}
  #readFile <- function() {
#  if(file.exists("F:/Projects/streamingtwitterapp/tweets.json"))
#    tweets <<- parseTweets("F:/Projects/streamingtwitterapp/tweets.json")
#}
