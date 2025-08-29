# frozen_string_literal: true

RSpec.describe MysqlCasualExplain do
  let(:explain_prefix) { ActiveRecord.version >= '7.0' ? 'EXPLAIN' : 'EXPLAIN for:' }
  before(:all) do
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))

    ENV.fetch('MYSQL_PING_ATTEMPTS', 1).to_i.times do
      break if ActiveRecord::Base.connection.raw_connection.ping
    rescue Mysql2::Error::ConnectionError
      sleep 1
    end

    %w[actor actor_info].each do |t|
      ActiveRecord::Base.connection.execute("ANALYZE TABLE #{t}")
    end
  end

  specify 'no problem' do
    expect(Actor.where(actor_id: 1).explain.inspect.sub(/\s*\(\d+\.\d+ sec\)/, '')).to eq <<~SQL
      #{explain_prefix} SELECT `actor`.* FROM `actor` WHERE `actor`.`actor_id` = 1
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      |  1 | SIMPLE      | actor | NULL       | const | PRIMARY       | PRIMARY | 2       | const |    1 |    100.0 | NULL  |
      +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
      1 row in set
    SQL
  end

  specify 'have a problem' do
    expect(Actor.all.explain.inspect.sub(/\s*\(\d+\.\d+ sec\)/, '')).to eq <<~SQL
      #{explain_prefix} SELECT `actor`.* FROM `actor`
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      |  1 | SIMPLE      | actor | NULL       | \e[1m\e[31mALL\e[0m  | \e[1m\e[31mNULL\e[0m          | \e[1m\e[31mNULL\e[0m | NULL    | NULL |  200 |    100.0 | NULL  |
      +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
      1 row in set
    SQL
  end

  specify 'have a problem (multi line)' do
    expect(Actor.joins('NATURAL JOIN actor_info').all.explain.inspect.sub(/\s*\(\d+\.\d+ sec\)/, '')).to eq <<~SQL
      #{explain_prefix} SELECT `actor`.* FROM `actor` NATURAL JOIN actor_info
      +----+--------------------+------------+------------+--------+-----------------------------------+-------------+---------+----------------------------------------------------------------------+------+----------+----------------+
      | id | select_type        | table      | partitions | type   | possible_keys                     | key         | key_len | ref                                                                  | rows | filtered | Extra          |
      +----+--------------------+------------+------------+--------+-----------------------------------+-------------+---------+----------------------------------------------------------------------+------+----------+----------------+
      |  1 | PRIMARY            | actor      | NULL       | \e[1m\e[31mALL\e[0m    | PRIMARY,idx_actor_last_name       | \e[1m\e[31mNULL\e[0m        | NULL    | NULL                                                                 |  200 |    100.0 | NULL           |
      |  1 | PRIMARY            | <derived2> | NULL       | ref    | <auto_key0>                       | <auto_key0> | 276     | sakila.actor.actor_id,sakila.actor.first_name,sakila.actor.last_name |   27 |    100.0 | NULL           |
      |  2 | DERIVED            | a          | NULL       | \e[1m\e[31mALL\e[0m    | \e[1m\e[31mNULL\e[0m                              | \e[1m\e[31mNULL\e[0m        | NULL    | NULL                                                                 |  200 |    100.0 | \e[1m\e[31mUsing filesort\e[0m |
      |  2 | DERIVED            | fa         | NULL       | ref    | PRIMARY                           | PRIMARY     | 2       | sakila.a.actor_id                                                    |   27 |    100.0 | Using index    |
      |  2 | DERIVED            | fc         | NULL       | ref    | PRIMARY                           | PRIMARY     | 2       | sakila.fa.film_id                                                    |    1 |    100.0 | Using index    |
      |  2 | DERIVED            | c          | NULL       | eq_ref | PRIMARY                           | PRIMARY     | 1       | sakila.fc.category_id                                                |    1 |    100.0 | NULL           |
      |  3 | \e[1m\e[31mDEPENDENT SUBQUERY\e[0m | fa         | NULL       | ref    | PRIMARY,idx_fk_film_id            | PRIMARY     | 2       | sakila.a.actor_id                                                    |   27 |    100.0 | Using index    |
      |  3 | \e[1m\e[31mDEPENDENT SUBQUERY\e[0m | f          | NULL       | eq_ref | PRIMARY                           | PRIMARY     | 2       | sakila.fa.film_id                                                    |    1 |    100.0 | NULL           |
      |  3 | \e[1m\e[31mDEPENDENT SUBQUERY\e[0m | fc         | NULL       | eq_ref | PRIMARY,fk_film_category_category | PRIMARY     | 3       | sakila.fa.film_id,sakila.c.category_id                               |    1 |    100.0 | Using index    |
      +----+--------------------+------------+------------+--------+-----------------------------------+-------------+---------+----------------------------------------------------------------------+------+----------+----------------+
      9 rows in set
    SQL
  end
end
