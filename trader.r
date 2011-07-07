t <- function() {
  source("trader.r")
}

r <- function() {
  remove(list=ls())
}

STK <- "PETR4"

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
  outer <- paste("select D as Date, O as Open, H as High, L as Low, C as Close, V as Volume from symbols where D in (",
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

gva <- function(data, n=21, dt=5, si=2) {
  ema <- EMA(data$C, n)
  vp <- rep(NA, length(ema))
  ac <- rep(NA, length(ema))
  for (i in (dt+1):length(ema)) {
    vp[i] <- 100*(ema[i]-ema[i-dt])/ema[i-dt]
    ac[i] <- vp[i] - vp[i-1]
  }
  mvp <- EMA(vp, si)
  mac <- EMA(ac, si)
  va <- data.frame(ema, mvp, mac)
  names(va) <- c("MA","Ve", "Ac")
  return(va)
}

gvidya <- function(data, n=9, sc=0.2) {
  cmo <- CMO(data$C, n) / 100
  vid <- rep(NA, length(cmo))
  i <- n + 1
  vid[i] <- data$C[i]*sc*abs(cmo[i])
  for (j in (i+1):length(cmo)) {
    vid[j] <- data$C[j]*sc*abs(cmo[j]) + vid[j-1]*(1-sc*abs(cmo[j]))
  }
  return(vid)
}

addVIDYA <- function(data, ...) {
  Vidya <- gta(data, gvidya(data))
  plot(addTA(Vidya, ...))
}

addVA <- function(data, colors=c("red", "blue"), ...) {
  va <- gva(data, ...)
  Ac <- gta(data, va$Ac)
  Ve <- gta(data, va$Ve)
  plot(addTA(Ac, on=NA, col=colors[1]))
  plot(addTA(Ve, on=NA, col=colors[2]))
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

read <- function(symbol = STK, ...) {
  gdb <<- gs(symbol, ...)
  ghc <<- ghlc(gdb)
  gxt <<- gxts(gdb)
}

test <- function(symbol = STK, f=TRUE) {
  read(symbol, limit=180)
  candleChart(gxt, multi.col=TRUE, theme="white")
  addEMAS(gdb)
  addSB(gdb, on=1, col="blue")
  addRSI(gdb, on=NA, col="blue")
  addADX(gdb, on=NA, col="blue")
  addVA(gdb)
  addVIDYA(gdb, on=NA, col="green")
}
                                        # TODO: Advanced Techniques
                                        # to be studied...
                                        # http://www.r-bloggers.com/artificial-intelligence-in-trading-k-means-clustering/
gkmeans <- function(symbol = STK) {
  read(symbol)
  x <- data.frame(d=index(Cl(gdb)),return=as.numeric(Delt(Cl(gdb))))
  ggplot(x,aes(return))+stat_density(colour="steelblue", size=2, fill=NA)+xlab(label='Daily returns')
}

gclplot <- function(symbol = STK, n=15) {
  read(symbol)
  nasa <- tail(cbind(Delt(Op(gxt), Hi(gxt)), Delt(Op(gxt), Lo(gxt)), Delt(Op(gxt), Cl(gxt))), -1)
  wss <- (nrow(nasa)-1)*sum(apply(nasa,2,var))
  for (i in 2:n) wss[i] = sum(kmeans(nasa, centers=i)$withinss)
  wss <- (data.frame(number=1:n,value=as.numeric(wss)))
  ggplot(wss,aes(number,value))+geom_point()+xlab("Number of Clusters")+ylab("Within groups sum of squares")+geom_smooth()
}

gcl <- function(symbol = STK, n=5, max=10) {
  read(symbol)
  nasa <- tail(cbind(Delt(Op(gxt),Hi(gxt)), Delt(Op(gxt), Lo(gxt)), Delt(Op(gxt), Cl(gxt))), -1)
  kmeanObject <- kmeans(nasa,n,iter.max=max)
  print(kmeanObject$centers)
  autocorrelation <- head(cbind(kmeanObject$cluster,lag(as.xts(kmeanObject$cluster),-1)),-1)
  xtabs(~autocorrelation[,1]+(autocorrelation[,2]))
  y <- apply(xtabs(~autocorrelation[,1]+(autocorrelation[,2])),1,sum)
  x <- xtabs(~autocorrelation[,1]+(autocorrelation[,2]))
  z <- x
  for(i in 1:n)
    {
      z[i,] <- (x[i,]/y[i])
    }
  round(z,2)
}
