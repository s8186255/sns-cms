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

function updateLocation(point){
    document.getElementById('latitude').value = point.y;
    document.getElementById('longitude').value = point.x;
    map.clearOverlays();
    map.addOverlay(new GMarker(new GLatLng(point.y,point.x)));

}