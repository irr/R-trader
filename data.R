gs <- function(symbol, dbname="./data/symbols.db", begin="", end="") {
  conn <- dbConnect("SQLite", dbname)
  sql1 <- "SELECT D, O, H, L, C, V from symbols where S = '"
  sql2 <- " ORDER BY D ASC"
  cond <- ""
  if (begin != "" && end != "") {
    cond <- paste(" AND D BETWEEN '", begin, "' AND '", end, "'", sep="")
  } else if (begin != "") {
    cond <- paste(" AND D >= '", begin, "'", sep="")
  } else if (end != "") {
    cond <- paste(" AND D <= '", end, "'", sep="")
  }
  query <- dbSendQuery(conn, statement=paste(sql1, symbol, "'", cond, sql2, sep=""))
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
  candleChart(x, multi.col=TRUE,theme="white")
}

gsb <- function(data, n=21) { # STARC Bands: http://www.investopedia.com/terms/s/starc.asp
  ema <- EMA(data$C, n) # Exponential moving average: http://en.wikipedia.org/wiki/Exponential_moving_average#Exponential_moving_average
  atr <- ATR(ghlc(data), n)[,2] # Average True Range: http://en.wikipedia.org/wiki/Average_True_Range
  sb <- data.frame(ema - abs(atr), ema + abs(atr))
  names(sb) <- c("Min", "Max")
  return(sb)
}
