#-- copyright
# ReportingEngine
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

# encoding: UTF-8
class Report::Transformer
  attr_reader :query

  def initialize(query)
    @query = query
  end

  ##
  # @return [Report::Result::Base] Result tree with row group bys at the top
  # @see Report::Chainable#result
  def row_first
    @row_first ||= query.result
  end

  ##
  # @return [Report::Result::Base] Result tree with column group bys at the top
  # @see Report::Walker#row_first
  def column_first
    @column_first ||= begin
      # reverse since we fake recursion ↓↓↓
      list = restructured.reverse
      all_fields = @all_fields.dup
      result = list.inject(@ungrouped) do |aggregate, (current_fields, type)|
        fields, all_fields = all_fields, all_fields - current_fields
        aggregate.grouped_by fields, type, current_fields
      end
      result or query.result
    end
  end

  ##
  # Important side effect: it sets @ungrouped, @all_fields.
  # @return [Array<Array<Array<String,Symbol>, Symbol>>] Group by fields + types (:row or :column)
  def restructured
    rows = []
    columns = []
    current = query.chain
    @all_fields = []
    until current.filter?
      @ungrouped = current.result if current.responsible_for_sql?
      list = current.row? ? rows : columns
      list << [current.group_fields, current.type]
      @all_fields.push(*current.group_fields)
      current = current.child
    end
    columns + rows
  end
end
