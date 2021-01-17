# MysqlCasualExplain

Highlight problematic MySQL explain results.

Inspired by [MySQLCasualLog.pm](https://gist.github.com/kamipo/839e8a5b6d12bddba539).

[![Gem Version](https://badge.fury.io/rb/mysql_casual_explain.svg)](https://badge.fury.io/rb/mysql_casual_explain)
[![Build Status](https://github.com/winebarrel/mysql_casual_explain/workflows/test/badge.svg?branch=master)](https://github.com/winebarrel/mysql_casual_explain/actions)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql_casual_explain'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mysql_casual_explain

## Usage

```ruby
#!/usr/bin/env ruby
require 'active_record'
require 'mysql_casual_explain'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  username: 'root',
  database: 'employees'
)

class Employee < ActiveRecord::Base; end

puts Employee.all.explain
```

![](https://user-images.githubusercontent.com/117768/89421006-7656dd00-d76e-11ea-844d-e0dd43ef8460.png)

## Test

```sh
docker-compose build
docker-compose run client bundle exec appraisal ar60 rake
```
