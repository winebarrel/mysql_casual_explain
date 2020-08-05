# frozen_string_literal: true

module MysqlCasualExplain
  SLOW_SELECT_TYPE_RE = Regexp.union(
    'DEPENDENT UNION',
    'DEPENDENT SUBQUERY',
    'UNCACHEABLE UNION',
    'UNCACHEABLE SUBQUERY'
  )

  SLOW_TYPE_RE = Regexp.union('index', 'ALL')
  SLOW_POSSIBLE_KEYS_RE = Regexp.union('NULL')
  SLOW_KEY_RE = Regexp.union('NULL')

  SLOW_EXTRA_RE = Regexp.union(
    'Using filesort',
    'Using temporary'
  )

  @warnings_by_column = {
    select_type: [
      ->(value) { SLOW_SELECT_TYPE_RE =~ value },
    ],
    type: [
      ->(value) { SLOW_TYPE_RE =~ value },
    ],
    possible_keys: [
      ->(value) { SLOW_POSSIBLE_KEYS_RE =~ value },
    ],
    key: [
      ->(value) { SLOW_KEY_RE =~ value },
    ],
    extra: [
      ->(value) { SLOW_EXTRA_RE =~ value },
    ],
  }

  class << self
    attr_accessor :warnings_by_column
  end
end
