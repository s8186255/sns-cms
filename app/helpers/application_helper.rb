# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #include TagsHelper
  def show_spinner
    content_tag "div", "Working... " + image_tag("rails_1.png"),
      :id => "ajax_busy", :style => "display:none;"
  end

  #nest layout
  def inside_layout(layout, &block)
    @template.instance_variable_set("@content_for_layout", capture(&block))

    layout = layout.include?("/") ? layout : "layouts/#{layout}" if layout
    buffer = eval("_erbout", block.binding)
    buffer.concat(@template.render_file(layout, true))
  end
end
