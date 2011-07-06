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
  stopifnot(dbHasCompleted(query))
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
  return(xts(d, order.by=as.Date(data[,1], "%Y-%m-%d")))
}

gta <- function(data, v) {
  return(xts(v, order.by=as.Date(data[,1], "%Y-%m-%d")))
}

addSB <- function(data, n=10, m=21, f=3, ...) {
                                        # STARC Bands: http://www.investopedia.com/terms/s/starc.asp
                                        # ATR: http://en.wikipedia.org/wiki/Average_True_Range
  ema <- EMA(data$C, m)
  atr <- ATR(ghlc(data), n)[,2]
  sb <- data.frame(ema - f*abs(atr), ema + f*abs(atr))
  names(sb) <- c("Min", "Max")
  SBMin <- gta(data, sb$Min)
  SBMax <- gta(data, sb$Max)
  plot(addTA(SBMin, ...))
  plot(addTA(SBMax, ...))
}

addEMAS <- function(data, n=10, colors=c("red", "violet"), ...) {
                                        # EMA: http://en.wikipedia.org/wiki/Exponential_moving_average#Exponential_moving_average
  plot(addEMA(n, col=colors[1]))
  plot(addEMA(n*5, col=colors[2]))
}

addRSI <- function(data, n=10, ...) {
                                        # RSI: http://www.investopedia.com/articles/technical/071601.asp
                                        # http://en.wikipedia.org/wiki/Relative_Strength_Index
                                        # The 30/70 on our scale represents the oversold/overbought positions
  rsi <- gta(data, RSI(data$C, n))
  plot(addTA(rsi, ...))
}

addADX <- function(data, n=10, ...) {
                                        # ADX: http://www.investopedia.com/articles/trading/07/adx-trend-indicator.asp
                                        # http://en.wikipedia.org/wiki/Average_Directional_Index
                                        #  00 -  25  Absent or Weak Trend
                                        #  25 -  50  Strong Trend
                                        #  50 -  75  Very Strong Trend
                                        #  75 - 100  Extremely Strong Trend
  adx <- gta(data, ADX(ghlc(data), n)[,4])
  plot(addTA(adx, ...))
}

test <- function() {
  db <<- gs("UOLL4")
  hlc <<- ghlc(db)
  candleChart(gxts(db)['2011-01::2011-06'], multi.col=TRUE, theme="white")
  addEMAS(db)
  addSB(db, on=1, col="blue")
  addRSI(db, on=NA, col="blue")
  addADX(db, on=NA, col="blue")
}
