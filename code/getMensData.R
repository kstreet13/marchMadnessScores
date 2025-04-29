require(rvest)
require(xml2)

links <- c('https://www.ncaa.com/news/basketball-men/article/2020-05-08/1985-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/1986-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-13/1987-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-13/1988-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-12/1989-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-18/1990-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-18/1991-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-14/1992-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-14/1993-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-13/1994-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-12/1995-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-11/1996-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-08/1997-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-08/1998-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/1999-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2000-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2001-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/2002-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2003-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2004-ncaa-tournament-brackets-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2005-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2006-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2007-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2008-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/2009-ncaa-tournament-bracket-scores-stats-rounds',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-12/2010-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-05/2011-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-11/2012-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-11/2013-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-10/2014-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-08/2015-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-07/2016-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/2017-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/2018-ncaa-tournament-bracket-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2020-05-06/2019-ncaa-tournament-bracket-scores-stats-records',
           NA,
           'https://www.ncaa.com/news/basketball-men/article/2022-07-20/2021-ncaa-bracket-scores-stats-records-march-madness-mens-tournament',
           'https://www.ncaa.com/news/basketball-men/article/2022-07-12/2022-ncaa-bracket-mens-march-madness-scores-stats-records',
           'https://www.ncaa.com/news/basketball-men/article/2023-04-18/2023-ncaa-bracket-scores-stats-march-madness-mens-tournament',
           'https://www.ncaa.com/news/basketball-men/article/2024-12-06/2024-ncaa-bracket-scores-stats-march-madness-mens-tournament'
           #'https://www.ncaa.com/news/basketball-men/article/2025-04-07/2025-march-madness-mens-ncaa-tournament-schedule-dates' # incomplete
)
names(links) <- 1985:2024
links <- links[!is.na(links)]


# functions for processing a page and an individual game
processGame <- function(game){
    teams <- unlist(strsplit(game, split=', '))
    teams <- gsub('^No[.] ','', teams)
    score <- sapply(teams, function(tm){
        x <- unlist(strsplit(tm, split=' '))
        return(x[length(x)])
    })
    teams <- gsub(' [0-9]+$','', teams)
    seeds <- sapply(teams, function(tm){ unlist(strsplit(tm, split=' '))[1] })
    teams <- gsub('[0-9]+ ','', teams)
    return(c(seed1 = seeds[1], team1 = teams[1], score1 = score[1], seed2 = seeds[2], team2 = teams[2], score2 = score[2]))
}
page2games <- function(page){
    text <- html_text(page)
    text <- gsub("\U00A0", " ", text) # a space is not always a space
    
    start <- '[0-9]+ NCAA [t|T]ournament:? [s|S]cores'
    stop <- '[0-9]+ NCAA [t|T]ournament:? [u|U]psets'
    
    idx <- regexpr(paste0(start,'.*',stop), text)
    
    text <- substr(text, idx, idx+attr(idx,'match.length'))
    text <- gsub('\t','', text)
    text <- unlist(strsplit(text, split="\n"))
    text <- text[grep('^ *$', text, invert = TRUE)] # empty lines
    if(length(grep('[0-9]+ NCAA [t|T]ournament:? [s|S]cores', text)) > 1){
        text <- text[(max(grep('[0-9]+ NCAA [t|T]ournament:? [s|S]cores', text))):length(text)]
    }
    text <- text[grep('[0-9]+ NCAA [t|T]ournament:? [s|S]cores', text, invert = TRUE)]
    text <- text[grep('[0-9]+ NCAA [t|T]ournament:? [u|U]psets', text, invert = TRUE)]
    text <- text[grep('^[a-zA-Z. ]* Regional', text, invert = TRUE)]
    text <- gsub(' [(][0-9]*OT[)]','', text) # remove OT annotation
    text <- gsub(' ?[|] Watch .*$','', text) # remove video link
    text <- gsub(' +$','', text)
    text <- gsub("No, ", "No. ", text) # common typo
    text <- gsub("^[a-zA-Z]*: No. ", "No. ", text) # remove region tags like "East: "
    if(text[7]=="West No. 11 Drake 53, No. 11 Wichita St. 52"){
        text[7] <- "No. 11 Drake 53, No. 11 Wichita St. 52"
    }
    if(text[10]=="No. 1 Louisville 74, No. 16 Morehead State 54"){ # 2009 missing game
        text <- c("Opening Round", "No. 16 Morehead State 58, No. 16 Alabama State 43", text)
    }
    
    is.game <- grep('^No. ',text)
    sameRound <- c(FALSE, is.game[-1] == is.game[-length(is.game)]+1)
    roundID <- cumsum(!sameRound)
    firstRound <- which(table(roundID) == 32)
    stopifnot(all(table(roundID)[firstRound:(firstRound+5)] == 2^(5:0)))
    round <- c(rep(0,sum(roundID < firstRound)), rep(2^(6:1), times=2^(5:0)))
    
    text <- text[grep('^No. ',text)]
    # text
    # fix typos and missing values
    if(text[54]=="No. 11 LSU 70, No. 2 Georgia Tech"){
        text[54] <- "No. 11 LSU 70, No. 2 Georgia Tech 64"
    }
    if(text[32]=="No. 8 Auburn, No. 9 San Diego 61"){
        text[32] <- "No. 8 Auburn 62, No. 9 San Diego 61"
    }
    if(text[8]=="No. 2 UConn 64, No. 15 Rider"){
        text[8] <- "No. 2 UConn 64, No. 15 Rider 46"
    }
    if(text[36]=="No. 10 Seton Hall 67, No. 2 Temple"){
        text[36] <- "No. 10 Seton Hall 67, No. 2 Temple 65"
    }
    if(text[47]=="No. 6 Purdue 66, No. 3 Oklahoma"){
        text[47] <- "No. 6 Purdue 66, No. 3 Oklahoma 62"
    }
    if(text[23]=="No. 10 Kent State 69, No. 7 Oklahoma State"){
        text[23] <- "No. 10 Kent State 69, No. 7 Oklahoma State 61"
    }
    if(text[36]=="No. 2 UConn 77, N.C. State 74"){
        text[36] <- "No. 2 UConn 77, No. 7 N.C. State 74"
    }
    if(text[16]=="No. 2 Pittsburgh, No. 15 Wagner 61"){
        text[16] <- "No. 2 Pittsburgh 87, No. 15 Wagner 61"
    }
    if(text[19]=="No. 8 Seton Hall 80, Arizona 76"){
        text[19] <- "No. 8 Seton Hall 80, No. 9 Arizona 76"
    }
    if(text[30]=="No. 3 Purdue 49, No. 13 Green Bay 48"){ # 1995
        text[30] <- "No. 3 Purdue 49, No. 14 Green Bay 48"
    }
    if(text[9]=="No. 16 Kentucky 110, No. 16 San Jose State 72"){ # 1996
        text[9] <- "No. 1 Kentucky 110, No. 16 San Jose State 72"
    }
    if(text[8]=="No. 10 NC State 75, UNC Charlotte 63"){
        text[8] <- "No. 10 NC State 75, No. 7 UNC Charlotte 63"
    }
    if(text[9]=="No. 2 UConn 77, UCF 71"){
        text[9] <- "No. 2 UConn 77, No. 15 UCF 71"
    }
    if(text[26]=="No. 1 UConn 103, Chattanooga 47"){
        text[26] <- "No. 1 UConn 103, No. 16 Chattanooga 47"
    }
    if(text[2]=="No. 16 Robert Morris 81, North Florida 77"){
        text[2] <- "No. 16 Robert Morris 81, No. 16 North Florida 77"
    }
    if(text[26]=="No. 11 Dayton 66, No 6 Providence 53"){
        text[26] <- "No. 11 Dayton 66, No. 6 Providence 53"
    }
    if(text[21]=="No. 1 North Carolina 103, Texas Southern 64"){
        text[21] <- "No. 1 North Carolina 103, No. 16 Texas Southern 64"
    }
    if(text[36]=="No. 8 Creighton 58, No. 7 Alabama 57"){ # 2012
        text[36] <- "No. 8 Creighton 58, No. 9 Alabama 57"
    }
    if(text[33]=="No. 5 VCU 88, No. 4 Akron 42"){ # 2013
        text[33] <- "No. 5 VCU 88, No. 12 Akron 42"
    }
    if(text[24]=="No. 4 Butler 76, No. 4 Winthrop 64"){ # 2017
        text[24] <- "No. 4 Butler 76, No. 13 Winthrop 64"
    }
    if(text[8]=="No. 13 Marshall 81, No. 14 Wichita State 75"){ # 2018
        text[8] <- "No. 13 Marshall 81, No. 4 Wichita State 75"
    }
    if(text[44]=="No. 4 Gonzaga 90, No. 5 Ohio State"){
        text[44] <- "No. 4 Gonzaga 90, No. 5 Ohio State 84"
    }
    if(text[7]=="No. 12 Oregon St. 70, No. Tennessee 56"){
        text[7] <- "No. 12 Oregon St. 70, No. 5 Tennessee 56"
    }
    if(text[11]=="No. 7 Texas 87 No. 10 Arizona State 85"){
        text[11] <- "No. 7 Texas 87, No. 10 Arizona State 85"
    }
    if(text[24]=="No. 4 Florida St. 64, No. 13 UNC Greensboro"){
        text[24] <- "No. 4 Florida St. 64, No. 13 UNC Greensboro 54"
    }
    if(text[27]=="No. 10 Iowa 79, No. 7 Temple 72"){
        text[27] <- "No. 10 Iowa 79, No. 7 Cincinnati 72" # wrong team
    }
    if(text[32]=="No. 13. North Texas 78, No. 4 Purdue 69"){
        text[32] <- "No. 13 North Texas 78, No. 4 Purdue 69"
    }
    if(text[19]=="No. 7 Oregon, No. 10 VCU | Canceled"){ # 2021
        text[19] <- "No. 7 Oregon 0, No. 10 VCU 0"
    }
    if(text[7]=="No. 5 Miami (FL) 63, No. 12 Drake (56)"){
        text[7] <- "No. 5 Miami (FL) 63, No. 12 Drake 56"
    }
    if(text[37]=="No. 1 Michigan State 54, No. 9 Ole Miss 66"){ # 1999
        text[37] <- "No. 1 Michigan State 74, No. 9 Ole Miss 66"
    }
    if(text[40]=="No. 4 Kentucky 71, No. 5 West Virginia 73"){
        text[40] <- "No. 4 Kentucky 71, No. 5 West Virginia 63"
    }
    if(text[46]=="No. 5 Colorado 53, No. 4 Florida St. 71"){
        text[46] <- "No. 4 Florida St. 71, No. 5 Colorado 53"
    }
    if(text[1]=="No. 1 Kansas 83, 16 Texas Southern 56"){
        text[1] <- "No. 1 Kansas 83, No. 16 Texas Southern 56"
    }
    
    games <- t(sapply(text, processGame, USE.NAMES = FALSE))
    colnames(games) <- c('seed1','team1','score1', 'seed2','team2','score2')
    games <- as.data.frame(games)
    for(ci in c(1,3,4,6)){
        games[,ci] <- as.numeric(games[,ci])
    }
    games$round <- round
    for(col in c('team1','team2')){
        games[games[,col] == 'Pitt',col] <- 'Pittsburgh'
        games[games[,col] == 'Arkansa',col] <- 'Arkansas'
        games[games[,col] == 'Loyola Chi.',col] <- 'Loyola Chicago'
        games[games[,col] == 'Wright St.',col] <- 'Wright State'
        games[games[,col] == 'NM St.',col] <- 'New Mexico St.'
        games[games[,col] == 'N. Carolina',col] <- 'North Carolina'
        games[games[,col] == 'Texas A&M-CC',col] <- 'Texas A&M - CC'
        games[games[,col] == 'Saint Mary’s',col] <- 'St. Mary’s'
        
        # remove unnecessary spaces
        games[,col] <- gsub('^ ','', games[,col])
        games[,col] <- gsub(' $','', games[,col])
    }
    return(games)
}


# get all the data
games <- lapply(seq_along(links), function(i){
    page <- read_html(x = links[i])
    gs <- page2games(page)
    gs$year <- as.numeric(names(links)[i])
    return(gs)
})
games <- do.call(rbind, games)


# save results
write.csv(games, file = 'MarchMadnessResults.csv', row.names = FALSE, quote=FALSE)
