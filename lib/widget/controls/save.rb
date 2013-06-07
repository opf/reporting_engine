class Widget::Controls::Save < Widget::Controls
  def render
    return "" if @subject.new_record? or !@options[:can_save]
    write link_to content_tag(:span, content_tag(:em, l(:button_save)), :class => "button-icon icon-save"), {},
      :href => "#", :id => "query-breadcrumb-save",
      :class => "button secondary",
      :title => l(:button_save),
      :"data-target" => url_for(:action => 'update', :id => @subject.id, :set_filter => '1')
  end
end
