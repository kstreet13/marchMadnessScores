require(rvest)

# expanded to 64 teams in 1994
links <- paste0('https://en.wikipedia.org/wiki/',1994:2025,'_NCAA_Division_I_women%27s_basketball_tournament')
names(links) <- 1994:2025
links <- links[names(links)!='2020']

# helper functions
cleanTab <- function(tab){
    tab <- as.matrix(tab)
    tab[is.na(tab)] <- ""
    tab <- gsub('[*]','', tab) # * can denote OT
    tab <- gsub('[†]','', tab) # † used for notes on hosting
    drop <- NULL
    for(ci in 1:ncol(tab)){
        if(all(tab[,ci] == "")){
            drop <- c(drop, ci)
        }
    }
    if(!is.null(drop)){
        tab <- tab[,-drop]
    }
    drop <- NULL
    for(ri in 1:nrow(tab)){
        if(all(tab[ri,] == "")){
            drop <- c(drop, ri)
        }
    }
    if(!is.null(drop)){
        tab <- tab[-drop,]
    }
    
    # find "OT" notations
    ot <- grep('OT$',tab)
    if(length(ot) > 0){
        fixed <- tab[ot]
        fixed <- gsub('OT','', fixed)
        fixed <- sapply(fixed, function(fix){
            if(as.numeric(fix) > 200){
                # probably multiple OTs (eg. "1214OT")
                fix <- gsub('[0-9]$','', fix)
            }
            return(fix)
        })
        tab[ot] <- fixed
    }
    
    return(tab)
}

findGames <- function(mat){
    index <- NULL
    for(ci in 1:(ncol(mat)-2)){
        for(ri in 1:(nrow(mat)-3)){
            if(all(grepl('^[0-9][0-9]?$', mat[ri:(ri+3), ci]))){
                if(all(grepl('^[0-9][0-9]?[0-9]?$', mat[ri:(ri+3), ci+2]))){
                    if(all(mat[ri, ci:(ci+2)] == mat[ri+1, ci:(ci+2)]) &
                       all(mat[ri+2, ci:(ci+2)] == mat[ri+3, ci:(ci+2)])){
                        index <- rbind(index, c(ri, ci))
                    }
                }
            }
        }
    }
    return(index)
}

processGame <- function(gameMat){
    stopifnot(all(gameMat[1,] == gameMat[2,]))
    stopifnot(all(gameMat[3,] == gameMat[4,]))
    gameMat <- gameMat[2:3,]
    ats <- grep('^at ', gameMat)
    if(length(ats) > 0){
        gameMat[ats] <- gsub('^at ','', gameMat[ats])
    }
    winner <- which.max(gameMat[,3])
    return(unname(c(gameMat[winner,], gameMat[3-winner,])))
}

processFirst4 <- function(tab){
    tab <- cleanTab(tab)
    tab <- tab[-1,]
    index <- findGames(tab)
    if(length(index) == 2){
        game <- processGame(tab[index[1]:(index[1]+3), index[2]:(index[2]+2)])
        return(c(game, 0)) # add round
    }else{
        return(NULL) # table is something other than a First Four game
    }
}

processRegion <- function(tab){
    tab <- cleanTab(tab)
    
    index <- findGames(tab)
    stopifnot(nrow(index) == 15)
    
    games <- t(sapply(1:nrow(index), function(ii){
        idx <- index[ii,]
        game <- tab[idx[1]:(idx[1]+3), idx[2]:(idx[2]+2)]
        return(processGame(game))
    }))
    games <- cbind(games, rep(c(64,32,16,8), times = c(8,4,2,1)))
    return(games)
}

processFinal4 <- function(tab){
    tab <- cleanTab(tab)
    
    # seeds could be (eg) "H1", "RW2" or alternately "GR1(1)", "SR3(2)"
    form1 <- grep('^[A-Z][A-Za-z]?[A-Za-z]?[0-9][0-9]?$', tab)
    form2 <- grep('^[0-9][0-9]?[A-Z][A-Z]?$', tab)
    form3 <- grep('^[A-Z][A-Z]?R?[0-9] ?[(][0-9][0-9]?[)]$', tab)
    form <- which.max(c(length(form1), length(form2), length(form3)))
    
    if(form == 1){
        tab[form1] <- gsub('[A-Za-z]','', tab[form1])
    }else if(form == 2){
        tab[form2] <- gsub('[A-Z]','', tab[form2])
    }else if(form == 3){
        tab[form3] <- gsub('^.*[(]','', tab[form3])
        tab[form3] <- gsub('[)]','', tab[form3])
    }else{
        stop('no form for seeds in final 4')
    }
    
    index <- findGames(tab)
    stopifnot(nrow(index) == 3)
    
    games <- t(sapply(1:nrow(index), function(ii){
        idx <- index[ii,]
        game <- tab[idx[1]:(idx[1]+3), idx[2]:(idx[2]+2)]
        return(processGame(game))
    }))
    games <- cbind(games, c(4,4,2))
    return(games)
}



# get all the data
games <- lapply(seq_along(links), function(i){
    page <- read_html(x = links[i])
    tabs <- html_table(page)
    dims <- sapply(tabs, dim)
    first4tabs <- tabs[dims[1,] == 6 & dims[2,] == 5]
    regiontabs <- tabs[dims[1,] == 48 & dims[2,] == 20]
    final4tab <- tabs[dims[1,] == 12 & dims[2,] == 10]
    
    games <- rbind(
        processRegion(regiontabs[[1]]),
        processRegion(regiontabs[[2]]),
        processRegion(regiontabs[[3]]),
        processRegion(regiontabs[[4]]),
        processFinal4(final4tab[[1]])
    )
    games <- games[order(as.numeric(games[,7]), decreasing = TRUE), ]
    if(length(first4tabs) > 0){
        first4 <- lapply(first4tabs, processFirst4)
        first4 <- do.call(rbind, first4)
        games <- rbind(
            first4, games
        )
    }
    colnames(games) <- c('seed1','team1','score1','seed2','team2','score2','round')
    games <- as.data.frame(games)
    for(col in c('seed1','score1','seed2','score2','round')){
        games[,col] <- as.numeric(games[,col])
    }
    games$year <- as.numeric(names(links)[i])
    
    # checks
    for(col in c('team1','team2')){
        games[games[,col] == 'Mississippi St.',col] <- 'Mississippi State'
        games[games[,col] == 'Penn St.',col] <- 'Penn State'
        games[games[,col] == 'Miami',col] <- 'Miami (FL)'
    }
    
    return(games)
})
games <- do.call(rbind, games)



# save results
write.csv(games, file = 'womensResults.csv', row.names = FALSE, quote=FALSE)
