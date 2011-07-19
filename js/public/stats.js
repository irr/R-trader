$(function() {
    $("#startdate").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: -365 });
    $("#enddate").datepicker({ dateFormat: 'yy-mm-dd'});
    $("#symbol").val("UOLL4");
    $("#startdate").val("2011-01-01");
    $("#enddate").val("2011-01-31");
    $("#plot").click(function(){
        var startdate = $("#startdate").val();
        var enddate = $("#enddate").val();
        var symbol = $("#symbol").val();
        if ((symbol.length < 4) || ((startdate.length + enddate.length) != 20)) {
            alert("Please verify input fields!");
            return;
        }
        $.getJSON('/load/' + symbol + '/'+startdate+"/"+enddate, function(data) {
            var db = data.db
            var ohlc = []
            for (var i = 0; i < db.length; i++) {
                var obj = db[i];
                var lst = [obj.D, obj.O, obj.H, obj.L, obj.C, obj.V];
                ohlc.push(lst);
            }
            $.jqplot('chart',[ohlc],{
                title: data.symbol,
                seriesDefaults:{yaxis:'y2axis'},
                axes: {
                    xaxis: {
                        renderer:$.jqplot.DateAxisRenderer,
                        tickOptions:{formatString:'%b %d, %y'},
                        min: ohlc[0][0],
                        max: ohlc[ohlc.length - 1][0]
                    },
                    y2axis: {
                        tickOptions:{formatString:'$%.4f'}
                    }
                },
                series: [{renderer:$.jqplot.OHLCRenderer, rendererOptions:{candleStick:true}}],
                highlighter: {
                    show: true,
                    showMarker:false,
                    tooltipAxes: 'xy',
                    yvalues: 4,
                    formatString:'<table class="jqplot-highlighter"><tr><td>Date:</td><td>%s</td></tr><tr><td>Open:</td><td>%s</td></tr><tr><td>High:</td><td>%s</td></tr><tr><td>Low:</td><td>%s</td></tr><tr><td>Close:</td><td>%s</td></tr></table>'
                }
            }).replot();
            $('#data').dataTable( {
                "bDestroy": true,
                "aaData": ohlc,
                "aoColumns": [
                    { "sTitle": "Date" },
                    { "sTitle": "Open", "sClass": "right" },
                    { "sTitle": "High", "sClass": "right" },
                    { "sTitle": "Low", "sClass": "right" },
                    { "sTitle": "Close", "sClass": "right" }
                ]
            } );

        });
    });
});

