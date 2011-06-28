conn <- dbConnect("SQLite", dbname = "/home/irocha/Books/trading/data/symbols.db")
query <- dbSendQuery(conn, statement = "SELECT D, O, H, L, C, V from symbols where S = 'UOLL4'")
trader <- fetch(query, n = -1)
dim(trader)
dbHasCompleted(query)
dbClearResult(query)
dbDisconnect(conn)
hlc <- data.frame(trader[3], trader[4], trader[5])
names(hlc) <- c("High", "Low", "Close")
ema <- EMA(trader[5], 7)[1:14]
atr <- ATR(hlc, 7)[,2][1:14]
env <- BBands(hlc, 7)[1:14]
adx <- ADX(hlc, 7)[1:14]
rsi <- RSI(hlc[3], 7)[1:14]
stk <- stoch(hlc, 7)[1:14]
ohlc <- data.frame(trader[2], trader[3], trader[4], trader[5], trader[6])
names(ohlc) <- c("Open", "High", "Low", "Close", "Volume")
data <- xts(ohlc, order.by=as.Date(trader[,1], "%Y-%m-%d"))
candleChart(data[1320:1357,], multi.col=TRUE,theme="white")





