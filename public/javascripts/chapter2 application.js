// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Ajax.Responders.register({
    onCreate: function(){
        if($('ajax_busy') && Ajax.activeRequestCount > 0){
            Effect.Appear('ajax_busy', {
                duration: 0.5,
                queue: 'end'
            });
        }
    },
    onComplete: function(){
        if($('ajax_busy') && Ajax.activeRequestCount == 0){
            Effect.Fade('ajax_busy', {
                duration: 0.5,
                queue: 'end'
            });
        }
    }
});
//google map test
var centerLatitude = 43.46 ;
var centerLongitude = 87.36 ;
var startZoom = 3;
var map;


function addMarker(latitude, longitude, description) {
    var marker = new GMarker(new GLatLng(latitude, longitude));
    GEvent.addListener(marker, 'click',
        function() {
            marker.openInfoWindowHtml(description);
        }
        );
    map.addOverlay(marker);
}

function init()
{
    if (GBrowserIsCompatible()) {
        map = new GMap2(document.getElementById("map"));
        map.addControl(new GSmallMapControl());map.addControl(new GMapTypeControl());
        map.setCenter(new GLatLng(centerLatitude, centerLongitude), startZoom);
        for(i=0; i<markers.size; i++) {
            addMarker(markers[i].latitude, markers[i].longitude, markers[i].name);
        }
    }
}
window.onload = init;
//window.onunload = GUnload;