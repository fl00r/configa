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

You can create `development.yml`, `staging.yml` or any other file, put it into the same folder as a base config file and Configa will automatically fetch and load it.

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
  videos:
    space: 1
    type: :block
  users:
    space: 2
    type: :block

# development.yml
mysql:
  database: my_database
tarantool:
  videos:
    type: :em
  users:
    type: :em
```

```ruby
config = Configa.new("config.yml")
config.development.mysq.database
#=> "my_database"
config.development.mysq.username
#=> "root"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
