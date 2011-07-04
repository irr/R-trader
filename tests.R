conn <- dbConnect("SQLite", dbname = "./data/symbols.db")
query <- dbSendQuery(conn, statement = "SELECT D, O, H, L, C, V from symbols where S = 'UOLL4'")
trader <- fetch(query, n = -1)
dim(trader)
dbHasCompleted(query)
dbClearResult(query)
dbDisconnect(conn)

hlc <- data.frame(trader[3], trader[4], trader[5])
names(hlc) <- c("High", "Low", "Close")

# Exponential moving average
# http://en.wikipedia.org/wiki/Exponential_moving_average#Exponential_moving_average
ema <- EMA(trader[5])

# Average True Range
# http://en.wikipedia.org/wiki/Average_True_Range
atr <- ATR(hlc)[,2]

# Bollinger Bands
# http://en.wikipedia.org/wiki/Bollinger_bands
# http://www.investopedia.com/articles/technical/102201.asp
# http://www.investopedia.com/articles/trading/05/022205.asp
env <- BBands(hlc)

# STARC Bands
# http://www.investopedia.com/terms/s/starc.asp
stc <- data.frame(ema - abs(atr), ema + abs(atr))

# Average Directional Index
# http://en.wikipedia.org/wiki/Average_Directional_Index
# http://www.investopedia.com/articles/trading/07/adx-trend-indicator.asp
# 00 -  25  Absent or Weak Trend
# 25 -  50  Strong Trend
# 50 -  75  Very Strong Trend
# 75 - 100  Extremely Strong Trend
adx <- ADX(hlc)

# Relative Strength Index
# http://en.wikipedia.org/wiki/Relative_Strength_Index
# http://www.investopedia.com/articles/technical/071601.asp
# The 30/70 on our scale represents the oversold/overbought positions
rsi <- RSI(hlc[3])

# Stochastic Oscillator 20/80
# http://en.wikipedia.org/wiki/Stochastic_oscillator
# http://www.investopedia.com/terms/s/stochasticoscillator.asp
stk <- stoch(hlc)

ohlc <- data.frame(trader[2], trader[3], trader[4], trader[5], trader[6])
names(ohlc) <- c("Open", "High", "Low", "Close", "Volume")
data <- xts(ohlc, order.by=as.Date(trader[,1], "%Y-%m-%d"))
candleChart(data[1320:1357,], multi.col=TRUE,theme="white")




