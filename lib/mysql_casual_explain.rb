# frozen_string_literal: true

require 'active_support'

require 'mysql_casual_explain/config'
require 'mysql_casual_explain/pretty_printer'
require 'mysql_casual_explain/version'

ActiveSupport.on_load :active_record do
  require 'active_record/connection_adapters/mysql/explain_pretty_printer'
  ActiveRecord::ConnectionAdapters::MySQL::ExplainPrettyPrinter.prepend MysqlCasualExplain::PrettyPrinter
end
