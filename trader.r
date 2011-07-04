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
  candleChart(x, multi.col=TRUE, theme="white")
}

vplot <- function(data, v) {
  return(xts(v, order.by=as.Date(data[,1], "%Y-%m-%d")))
}

gsb <- function(data, n=21) { # STARC Bands: http://www.investopedia.com/terms/s/starc.asp
  ema <- EMA(data$C, n) # http://en.wikipedia.org/wiki/Exponential_moving_average#Exponential_moving_average
  atr <- ATR(ghlc(data), n)[,2] # http://en.wikipedia.org/wiki/Average_True_Range
  sb <- data.frame(ema - abs(atr), ema + abs(atr))
  names(sb) <- c("Min", "Max")
  return(sb)
}

addSBMin <- function(data, n=21) {
  sb <- gsb(data, n)
  SBMin <- vplot(data, sb$Min)
  addTA(SBMin, on=1)
}

addSBMax <- function(data, n=21) {
  sb <- gsb(data, n)
  SBMax <- vplot(d, sb$Max)
  addTA(SBMax, on=1)
}

test <- function() {
  d <- gs("UOLL4", limit=30)
  gplot(gxts(d))
}
