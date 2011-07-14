$(function() {
    $("#startdate").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: -365 });
    $("#enddate").datepicker({ dateFormat: 'yy-mm-dd'});
    $("#plot").click(function(){
        var startdate = $("#startdate").val();
        var enddate = $("#enddate").val();
        if ((startdate.length + enddate.length) != 20) {
            alert("Please verify date fields!");
            return;
        }
        $.getJSON('/load/UOLL4/'+startdate+"/"+enddate, function(data) {
            var db = data.db
            var ohlc = []
            for (var i = 0; i < db.length; i++) {
                var obj = db[i];
                var lst = [obj.D, obj.O, obj.H, obj.L, obj.C];
                ohlc.push(lst);
            }
            plot1 = $.jqplot('chart1',[ohlc],{
                title: 'Chart',
                seriesDefaults:{yaxis:'y2axis'},
                axes: {
                    xaxis: {
                        renderer:$.jqplot.DateAxisRenderer,
                        tickOptions:{formatString:'%b %e'},
                        min: ohlc[0][0],
                        max: ohlc[ohlc.length - 1][0]
                    },
                    y2axis: {
                        tickOptions:{formatString:'$%d'}
                    }
                },
                series: [{renderer:$.jqplot.OHLCRenderer, rendererOptions:{candleStick:true}}],
                highlighter: {
                    show: true,
                    showMarker:false,
                    tooltipAxes: 'xy',
                    yvalues: 4,
                    formatString:'<table class="jqplot-highlighter"> \
<tr><td>date:</td><td>%s</td></tr> \
<tr><td>open:</td><td>%s</td></tr> \
<tr><td>hi:</td><td>%s</td></tr> \
<tr><td>low:</td><td>%s</td></tr> \
<tr><td>close:</td><td>%s</td></tr></table>'
                }
            });
        });
    });
});

