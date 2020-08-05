# frozen_string_literal: true

module MysqlCasualExplain
  module PrettyPrinter
    COLUMNS = %i[
      id
      select_type
      table
      type
      possible_keys
      key
      key_len
      ref
      rows
      extra
    ].freeze

    BOLD = ActiveSupport::LogSubscriber::BOLD
    RED = ActiveSupport::LogSubscriber::RED
    CLEAR = ActiveSupport::LogSubscriber::CLEAR

    def build_cells(items, widths)
      items, widths = _colorize_items(items, widths) if items.first != 'id'
      super(items, widths)
    end

    private

    def _colorize_items(items, widths)
      item_by_column = COLUMNS.zip(items).to_h
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
