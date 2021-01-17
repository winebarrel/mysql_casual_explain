# frozen_string_literal: true

module MysqlCasualExplain
  module PrettyPrinter
    BOLD = ActiveSupport::LogSubscriber::BOLD
    RED = ActiveSupport::LogSubscriber::RED
    CLEAR = ActiveSupport::LogSubscriber::CLEAR

    def pp(result, elapsed)
      widths    = compute_column_widths(result)
      separator = build_separator(widths)

      pp = []

      pp << separator
      pp << build_cells(result.columns, result.columns, widths)
      pp << separator

      result.rows.each do |row|
        pp << build_cells(result.columns, row, widths)
      end

      pp << separator
      pp << build_footer(result.rows.length, elapsed)

      "#{pp.join("\n")}\n"
    end

    private

    def build_cells(columns, items, widths)
      items, widths = _colorize_items(columns, items, widths) if items.first != 'id'
      super(items, widths)
    end

    def _colorize_items(columns, items, widths)
      columns = columns.map(&:downcase).map(&:to_sym)
      item_by_column = columns.zip(items).to_h
      warnings_by_column = MysqlCasualExplain.warnings_by_column

      new_items = []
      new_widths = []
      extra_len = "#{BOLD}#{RED}#{CLEAR}".length

      item_by_column.each_with_index do |(column, item), i|
        item = 'NULL' if item.nil?
        warnings = warnings_by_column.fetch(column, [])

        if warnings.any? { |w| w.call(item) }
          new_items << "#{BOLD}#{RED}#{item}#{CLEAR}"
          new_widths << widths[i] + extra_len
        else
          new_items << item
          new_widths << widths[i]
        end
      end

      [new_items, new_widths]
    end
  end
end
