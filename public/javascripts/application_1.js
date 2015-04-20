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
var startZoom = 12;
var map;


function init1() {
    if (GBrowserIsCompatible()){
        map = new GMap2(document.getElementById("map"));
        map.addControl(new GSmallMapControl());
        map.addControl(new GMapTypeControl());
        map.setCenter(new GLatLng(centerLatitude, centerLongitude), startZoom);

        //allow the user to click the map to create a marker
        GEvent.addListener(map, "click", function(overlay, latlng) {
            //创建一个泪滴样的标记
            var marker = new GMarker(latlng);
            map.addOverlay(marker);
            //create an HTML DOM form element
            var inputForm = document.createElement("form");
            inputForm.setAttribute("action","");
            inputForm.onsubmit = function() {
                createMarker(); return false;
            };
            //retrieve the longitude and lattitude of the click point
            var lng = latlng.lng();
            var lat = latlng.lat();
            inputForm.innerHTML = '<fieldset style="width:150px;">'
            + '<legend>New Marker</legend>'
            + '<label for="found">Found</label>'
            + '<input type="text" id="found" name="m[found]" style="width:100%;"/>'
            + '<label for="left">Left</label>'
            + '<input type="text" id="left" name="m[left]" style="width:100%;"/>'
            + '<input type="submit" value="Save"/>'
            + '<input type="hidden" id="longitude" name="m[lng]" value="'+ lng +'"/>'
            + '<input type="hidden" id="latitude" name="m[lat]" value="' + lat + '"/>'
            + '</fieldset>';
            //map.openInfoWindow (latlng,document.createTextNode("You clicked here!"));
            map.openInfoWindow (latlng,inputForm);
        });

    }
}

//创建marker
function createMarker(){
    var lng = document.getElementById("longitude").value;
    var lat = document.getElementById("latitude").value;
    var getVars =  "?m[found]=" + document.getElementById("found").value
    + "&m[left]=" + document.getElementById("left").value
    + "&m[lng]=" + lng
    + "&m[lat]=" + lat ;
    var request = GXmlHttp.create();
    //call the create action back on the server
    request.open('GET', 'create' + getVars, true);
    request.onreadystatechange = function() {
        if (request.readyState == 4) {
            //the request is complete
            var success=false;
            var content='Error contacting web service';
            try {
                //parse the result to JSON (simply by eval-ing it)
                res=eval( "(" + request.responseText + ")" );
                content=res.content;
                success=res.success;
            }catch (e){
                success=false;
            }
            //check to see if it was an error or success
            if(!success) {
                alert(content);
            } else {
                //create a new marker and add its info window
                var latlng = new GLatLng(parseFloat(lat),parseFloat(lng));
                var marker = addMarkerToMap(latlng, content);
                map.addOverlay(marker);
                map.closeInfoWindow();
            }
        }
    }
    request.send(null);
    return false;
}

//添加marker到地图上
function addMarkerToMap(latlng, html) {
    var marker = new GMarker(latlng);
    GEvent.addListener(marker, 'click', function() {
        var markerHTML = html;
        marker.openInfoWindowHtml(markerHTML);
    });
    return marker;
}
window.onload = init1;
//window.onunload = GUnload;