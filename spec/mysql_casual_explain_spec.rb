# frozen_string_literal: true

RSpec.describe MysqlCasualExplain do
  before(:all) do
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

    ENV.fetch('MYSQL_PING_ATTEMPTS', 1).to_i.times do
      break if ActiveRecord::Base.connection.raw_connection.ping
    rescue Mysql2::Error::ConnectionError
      sleep 1
    end

    ActiveRecord::Base.connection.execute('ANALYZE TABLE actor')
  end

  specify 'no problem' do
    expect(Actor.where(actor_id: 1).explain.sub(/\s*\(\d+\.\d+ sec\)/, '')).to eq <<~SQL
      EXPLAIN for: SELECT `actor`.* FROM `actor` WHERE `actor`.`actor_id` = 1
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      |  1 | SIMPLE      | actor | NULL       | const | PRIMARY       | PRIMARY | 2       | const |    1 |    100.0 | NULL  |
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      1 row in set
    SQL
  end

  specify 'have a problem' do
    expect(Actor.all.explain.sub(/\s*\(\d+\.\d+ sec\)/, '')).to eq <<~SQL
      EXPLAIN for: SELECT `actor`.* FROM `actor`
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      |  1 | SIMPLE      | actor | NULL       | \e[1m\e[31mALL\e[0m  | \e[1m\e[31mNULL\e[0m          | \e[1m\e[31mNULL\e[0m | NULL    | NULL |  200 |    100.0 | NULL  |
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      1 row in set
    SQL
  end
end
