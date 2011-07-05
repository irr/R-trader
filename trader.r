t <- function() {
  source("trader.r")
}

gs <- function(symbol, dbname="./data/symbols.db", limit=0, begin="", end="") {
  conn <- dbConnect("SQLite", dbname)
  where <- paste("where S ='", symbol, "'", sep="")
  limit <- ifelse(limit>0, paste(" limit ", limit, sep=""), "")
  cond <- ""
  if (begin != "" && end != "") {
    cond <- paste("and D between '", begin, "' and '", end, "'", sep="")
  } else if (begin != "") {
    cond <- paste("and D >= '", begin, "'", sep="")
  } else if (end != "") {
    cond <- paste("and D <= '", end, "'", sep="")
  }
  inner <- paste("select D from symbols",
                 where, cond,
                 "order by D desc",
                 limit, sep= " ")
  outer <- paste("select D, O, H, L, C, V from symbols where D in (",
                 inner,
                 ") and S = '",
                 symbol,
                 "' order by D asc",
                 sep="")
  query <- dbSendQuery(conn, statement=outer)
  results <- fetch(query, n=-1)
  dbHasCompleted(query)
  dbClearResult(query)
  dbDisconnect(conn)
  return(results)
}

ghlc <- function(data) {
  d <- data.frame(data[3], data[4], data[5])
  names(d) <- c("High", "Low", "Close")
  return(d)
}

gxts <- function(data) {
  d <- data.frame(data[2], data[3], data[4], data[5], data[6])
  names(d) <- c("Open", "High", "Low", "Close", "Volume")
  x <- xts(d, order.by=as.Date(data[,1], "%Y-%m-%d"))
  return(x)
}

gplot <- function(x) {
  Rtrader <- x
  candleChart(Rtrader, multi.col=TRUE, theme="white")
}

gvplot <- function(data, v) {
  return(xts(v, order.by=as.Date(data[,1], "%Y-%m-%d")))
}

gsb <- function(data, m=21, n=10, f=3) { # STARC Bands: http://www.investopedia.com/terms/s/starc.asp
  ema <- EMA(data$C, m) # http://en.wikipedia.org/wiki/Exponential_moving_average#Exponential_moving_average
  atr <- ATR(ghlc(data), n)[,2] # http://en.wikipedia.org/wiki/Average_True_Range
  sb <- data.frame(ema - f*abs(atr), ema + f*abs(atr))
  names(sb) <- c("Min", "Max")
  return(sb)
}

grsi <- function(data, n=10) { # RSI: http://www.investopedia.com/articles/technical/071601.asp
  return(RSI(ghlc(data)$C, n)) # http://en.wikipedia.org/wiki/Relative_Strength_Index
}

addSB <- function(data, n=10) {
  sb <- gsb(data, n)
  SBMin <- gvplot(data, sb$Min)
  SBMax <- gvplot(data, sb$Max)
  plot(addTA(SBMin, on=1, col="blue"))
  plot(addTA(SBMax, on=1, col="blue"))
  plot(addEMA(n=10,col="red"))
  plot(addEMA(n=50,col="green"))
}

addRSI <- function(data, n=10) {
  rsi <- gvplot(data, grsi(data, n)) # The 30/70 on our scale represents the oversold/overbought positions
  plot(addTA(rsi, on=NA, col="blue"))
}

test <- function() {
  db <<- gs("UOLL4", begin="2010-06-16")
  hlc <<- ghlc(db)
  gplot(gxts(db))
  addSB(db)
  addRSI(db)
}
