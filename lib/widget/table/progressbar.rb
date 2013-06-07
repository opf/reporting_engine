class Widget::Table::Progressbar < Widget::Base
  dont_cache!

  # Defines the minimum number of cells for a 'big' report
  # Big reports may be handled differently in the UI - i.e. ask the user
  # if he's really sure to execute such a heavy report
  THRESHHOLD = 2000

  def render
    if render_table?
      render_widget Widget::Table, @subject, :to => (@output ||= "".html_safe)
    else
      write(content_tag(:label, :style => "display:none") do
        content_tag(:div, l(:label_progress_bar_explanation).html_safe) + render_progress_bar
      end)
    end
  end

  def render_table?
    Widget::Table.new(@subject).resolve_table.new(@subject).cached? || @subject.size <= THRESHHOLD
  end

  def render_progress_bar
    content_tag(:div, "",
                :id => "progressbar",
                :class => "form_controls",
                :"data-query-size" => @subject.size,
                :"data-translation" => ::I18n.translate(:label_load_query_question, :size => @subject.size),
                :"data-target" => url_for(:action => 'index', :set_filter => '1', :immediately => true))
  end
end
