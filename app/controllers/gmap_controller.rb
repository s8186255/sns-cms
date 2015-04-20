# To change this template, choose Tools | Templates
# and open the template in the editor.

class GmapController < ApplicationController
  def new
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.center_zoom_init([22.792388,79.497070],4)
    @map.overlay_init(GMarker.new([22.792388,79.497070],:title =>"India", :info_window =>"India"))
    @map.record_init @map.add_overlay(GMarker.new([22.792388, 72.421875],:title =>"Ahmedabad", :info_window =>"Ahmedabad"))
    #@map.add_overlay(GMarker.new([22.792388, 72.421875],:title =>"Ahmedabad", :info_window =>"Ahmedabad"))
  end
  def map


  end

  def create
    marker = Marker.new(params[:m])
    if marker.save
      res={:success=>true,:content=>"<div><strong>found </strong>#{marker.found}
</div><div><strong>left </strong>#{marker.left}</div>"}
    else
      res={:success=>false,:content=>"Could not save the marker"}
    end
    render :text=>res.to_json
  end
end
