#make sure to require Widget::Filters::Base first because otherwise
#ruby might find Base within Widget and Rails will not load it
require_dependency 'widget/filters/base'
class Widget::Filters::RemoveButton < Widget::Filters::Base
  def render
    write(content_tag(:td, :width => "25px") do
      hidden_field = tag :input, :id => "rm_#{filter_class.underscore_name}",
        :name => "fields[]", :type => "hidden", :value => ""
      button = tag :input, :type => "button", :value => "",
        :class => "icon filter_rem icon-filter-rem", :title => l(:description_remove_filter)
      content_tag(:div, hidden_field + button, :id => "rm_box_#{filter_class.underscore_name}", :class => "remove-box")
    end)
  end
end
