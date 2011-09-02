========
R-trader
========

About
-----
Mechanical Trading System using R

Dependencies
------------
- R (quantmod, RSQLite)
- SQLite3
- Node.js (sqlite3, node-static)
- jqPlot
- JQuery UI

Setup
-----
From inside **R-trader/data** directory, create sample data base typing::

 [irocha@napoleon data (master)]$ ./createsqlitedb.sh 
 Cleaning up...
 Extracting SQL file...
 Generating csv from SQL file...
 Creating SQLite3 database...
 Removing temporary files...
 Done.

After installing R packages (command: **install.packages(c("RSQLite", "quantmod"))**), from inside **R-trader** base directory type::

 [irocha@napoleon R-trader (master)]$ R

 R version 2.12.1 (2010-12-16)
 Copyright (C) 2010 The R Foundation for Statistical Computing
 ISBN 3-900051-07-0
 Platform: i686-pc-linux-gnu (32-bit)

 R is free software and comes with ABSOLUTELY NO WARRANTY.
 You are welcome to redistribute it under certain conditions.
 Type 'license()' or 'licence()' for distribution details.

   Natural language support but running in an English locale

 R is a collaborative project with many contributors.
 Type 'contributors()' for more information and
 'citation()' on how to cite R or R packages in publications.

 Type 'demo()' for some demos, 'help()' for on-line help, or
 'help.start()' for an HTML browser interface to help.
 Type 'q()' to quit R.

 Loading required package: quantmod
 Loading required package: Defaults
 Loading required package: xts
 Loading required package: zoo
 Loading required package: stats

 Attaching package: 'zoo' 

 The following object(s) are masked from 'package:base':

     as.Date

 Loading required package: TTR
 Loading required package: RSQLite
 Loading required package: DBI
 > test()

**IMPORTANT**: remember to change your project directory inside files::

 [irocha@napoleon R-trader (master)]$ more .Rprofile 
 options(papersize="a4")
 options(editor="emacs")
 options(pdfviewer="evince")

 .First <- function() {
   require(quantmod)
   require(RSQLite)
   setwd("/home/irocha/git/R-trader")  <<< change this!
   source("trader.r")
 }
 
 [irocha@napoleon R-trader (master)]$ more trader.r 
 t <- function() {
   source("trader.r")
 }

 STK <- "PETR4"

 # remember to change dbname! <<< SQLite sample database complete path
 gs <- function(symbol, dbname="./data/symbols.db", limit=0, begin="", end="") { 
   conn <- dbConnect("SQLite", dbname)
   ...


Author
------
Ivan Ribeiro Rocha <ivan.ribeiro@gmail.com> 

Copyright and License
---------------------

`BOLA - Buena Onda License Agreement (v1.1) <http://blitiri.com.ar/p/bola/>`_ 

This work is provided 'as-is', without any express or implied warranty. In no
event will the authors be held liable for any damages arising from the use of
this work.

To all effects and purposes, this work is to be considered Public Domain.

However, if you want to be "buena onda", you should:

1. Not take credit for it, and give proper recognition to the authors.
2. Share your modifications, so everybody benefits from them.
3. Do something nice for the authors.
4. Help someone who needs it: sign up for some volunteer work or help your
   neighbour paint the house.
5. Don't waste. Anything, but specially energy that comes from natural
   non-renewable resources. Extra points if you discover or invent something
   to replace them.
6. Be tolerant. Everything that's good in nature comes from cooperation.

