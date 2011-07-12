t <- function() {
  source("trader.r")
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

HLC <- function(data) {
  d <- data.frame(data[3], data[4], data[5])
  names(d) <- c("High", "Low", "Close")
  return(d)
}

XTS <- function(data) {
  d <- data.frame(data[2], data[3], data[4], data[5], data[6])
  names(d) <- c("Open", "High", "Low", "Close", "Volume")
  return(xts(d, order.by=as.Date(data[,1], "%Y-%m-%d")))
}

read <- function(symbol = STK, ...) {
  gdb <<- gs(symbol, ...)
  ghc <<- HLC(gdb)
  gxt <<- XTS(gdb)
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
