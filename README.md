# Configa

Configa makes it easier to use multi environment YAML configs.

Inspired by [prepor](https://github.com/prepor)

## Installation

Add this line to your application's Gemfile:

    gem 'configa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configa

## Usage

```ruby
config_file_path = File.expand_path("../config/config.yml", __FILE__)
config = Configa.new(config_file_path)
config.mysql.host
#=> "localhost"
config.development.mongodb.user
#=> "pedro"
config.development.mongodb(:user, :password)
#=> ["pedro", "password"]
config.production.root.password
#=> Error is raised ;)
```

## Why anyone needs configa?

You can specify in your config file many environments without duplication

```yaml
mysql:
  adapter: mysql
  encoding: utf8
  host: localhost
  username: root

development:
  mysql:
    database: mysql_dev

test:
  mysql:
    database: mysql_test

production:
  mysql:
    username: admin
    password: strongone
```

So, it will create `mysql` "node" which will be shared between all of environments:

```ruby
config.development.mysql.username
#=> "root"
config.production.mysql.username
#=> "admin"
config.production.mysql(:username, :host)
#=> ["admin", "localhost"]
```

Also you can share base templates between multiple nodes of one environment

```yaml
mysql:
  adapter: mysql
  encoding: utf8
  host: localhost
  username: root

development:
  databases:
    users:
      mysql:
        database: users_dev
    blogs:
      mysql:
        database: blogs_dev
```

```ruby
config.development.databases.users.mysql.database
#=> "users_dev"
```

## Sometimes configuration files grows

You can create `development.yml`, `staging.yml` or any other file, put it into the same folder as a base config file and Configa will automatically fetch and load it. Also you can use cascade templates. For example in following example you can define `tarantool` namespace, wich will be inherited by `tarantool` namespace in "development" env.

```yaml
# config.yml
mysql:
  adapter: mysql
  encoding: utf8
  host: localhost
  username: root
tarantool:
  host: localhost
  port: 13013
  type: :block

# development.yml
mysql:
  database: my_database
tarantool:
  type: :em
videos:
  tarantool:
    space: 1
users:
  tarantool:
    space: 2
```

```ruby
config = Configa.new("config.yml")
config.development.mysql.database
#=> "my_database"
config.development.mysql.username
#=> "root"
config.videos.tarantool.space
#=> 1
config.videos.tarantool.type
#=> :em
```

All properties that defined higher in the tree will rewrite root properties:

```yaml
database:
  adapter: sqlite
  user: root

development:
  database:
    db: dev_sqlite

staging:
  database:
    adapter: mysql
  internal_servers:
    database:
      db: internal_db
  external_servers:
    database:
      db: external_db
      user: external_root
```

So you can see how for whole staging node we rewrite database adapter, then for each subnode we specify other properties.

Also you can define default environment:

```ruby
dev = Configa.new(path, env: development)
all = Configa.new(path)

dev.mysql
# the same as
all.development.mysql

dev.production.mysql
# will raise an error
all.production.mysql
# will return mysql for production
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
