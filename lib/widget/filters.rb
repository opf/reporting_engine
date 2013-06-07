class Widget::Filters < Widget::Base

  def render
    table = content_tag :table, :width => "100%" do
      content_tag :tr do
        content_tag :td do
          content_tag :table, :id => "filter_table", :cellspacing => '0' do
            render_filters
          end
        end
      end
    end
    select = content_tag :div, :id => "add_filter_block" do
      label = label_tag 'add_filter_select',l(:label_filter_add), :class => 'hidden-for-sighted'
      add_filter = select_tag 'add_filter_select',
          options_for_select([["-- #{l(:label_filter_add)} --",'']] + selectables),
            :class => "select-small",
            :name => nil
      add_filter += maybe_with_help :icon => { :class => 'filter-icon' },
                                   :tooltip => { :class => 'filter-tip' },
                                   :instant_write => false # help associated with this kind of Widget
      (label + add_filter).html_safe
    end
    write content_tag(:div, table + select)
  end

  def selectables
    filters = engine::Filter.all
    filters.sort_by do |filter|
      filter.label
    end.select do |filter|
      filter.selectable?
    end.collect do |filter|
      [ filter.label, filter.underscore_name ]
    end
  end

  def render_filters
    active_filters = @subject.filters.select { |f| f.display? }
    engine::Filter.all.select do |filter|
      filter.selectable?
    end.collect do |filter|
      opts = {:id => "tr_#{filter.underscore_name}",
              :class => "#{filter.underscore_name} filter",
              :"data-filter-name" => filter.underscore_name }
      active_instance = active_filters.detect { |f| f.class == filter }
      if active_instance
        opts[:"data-selected"] = true
      else
        opts[:style] = "display:none"
      end
      content_tag :tr, opts do
        render_filter filter, active_instance
      end
    end.join.html_safe
  end

  def render_filter(f_cls, f_inst)
    f = f_inst || f_cls
    html = ''.html_safe
    render_widget Label, f, :to => html
    render_widget Operators, f, :to => html
    if f_cls.heavy?
      render_widget Heavy, f, :to => html
    elsif engine::Operator.string_operators.all? { |o| f_cls.available_operators.include? o }
      render_widget TextBox, f, :to => html
    elsif engine::Operator.time_operators.all? { |o| f_cls.available_operators.include? o }
      render_widget Date, f, :to => html
    elsif engine::Operator.integer_operators.all? {|o| f_cls.available_operators.include? o }
      if f_cls.available_values.empty?
        render_widget TextBox, f, :to => html
      else
        render_widget MultiValues, f, :to => html, :lazy => true
      end
    else
      if f_cls.is_multiple_choice?
        render_widget MultiChoice, f, :to => html
      else
        render_widget MultiValues, f, :to => html, :lazy => true
      end
    end
    render_filter_help f, :to => html
    render_widget RemoveButton, f, :to => html
  end

  ##Renders help for a filter (chainable)
  def render_filter_help(filter, options = {})
    html = content_tag :td, :width => "25px" do
      if filter.help_text # help associated with the chainable this Widget represents
        render_widget Widget::Controls::Help, filter.help_text
      end
    end
    if canvas = options[:to]
      canvas << "\n" << html
    else
      html
    end
  end
end
