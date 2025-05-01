# check data integrity / internal consistency

# games <- read.csv('womensResults.csv')
games <- read.csv('mensResults.csv')

# if this runs with no errors, then the data probably doesn't contain any errors of the specific types for which we checked
for(year in unique(games$year)){
    g <- games[which(games$year == year), ]
    
    # check there are no missing/NA values
    stopifnot(sum(is.na(g)) == 0)
    stopifnot(sum(g == "") == 0)
    
    # all seed, score, round, and year values are numeric
    for(col in c('seed1','score1','seed2','score2','round','year')){
        stopifnot(is.numeric(g[,col]))
    }
    
    # check that there are 64+[number of play-in games] teams 
    stopifnot(length(unique(c(g$team1,g$team2))) == 64 + sum(g$round==0))
    
    # check that there are 4 of each seed in the round of 64
    stopifnot(all(table(c(g$seed1[g$round==64], g$seed2[g$round==64])) == 4))
    
    # check that all first round games are between appropriate seeds (1-16, 2-15, etc.)
    stopifnot(all(g$seed1[g$round==64] == 17 - g$seed2[g$round==64]))
    
    # check that the winner is always team1
    if(!all(g$score1 > g$score2)){
        stopifnot(all(g$score1 >= g$score2))
        stopifnot(sum(g$score1 == g$score2) == 1) # Oregon/VCU
    }
    
    # check that each winner advances and each loser does not
    for(i in 1:(nrow(g)-1)){
        w <- g$team1[i]
        stopifnot(w %in% c(g$team1[(i+1):nrow(g)], g$team2[(i+1):nrow(g)]))
        l <- g$team2[i]
        stopifnot(!l %in% c(g$team1[(i+1):nrow(g)], g$team2[(i+1):nrow(g)]))
    }
}
