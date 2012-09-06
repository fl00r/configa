# encoding: utf-8
require 'spec_helper'

describe Configa do

  describe Configa::MagicContainer do
    it "basic test for one file config" do
      path = File.expand_path("../../config.yml", __FILE__)
      configa = Configa::MagicContainer.new(path)
      mysql = configa.instance_variable_get(:"@yaml")["mysql"]
      dev = configa.instance_variable_get(:"@yaml")["development"]
      dev["mysql"]["adapter"].must_equal mysql["adapter"]
      dev["mysql"]["database"].must_equal "mysql_dev"
      proc{ configa.staging.prestaging.mysql.port}.must_raise Configa::UnknownKey
      configa.staging.prestaging.mysql.adapter.must_equal "mysql"
      configa.staging.prestaging.users.mysql.adapter.must_equal "mysql"
      configa.staging.prestaging.users.mysql.username.must_equal "test"
      configa.staging.prestaging.users.mysql.database.must_equal "users"
      configa.staging.prestaging.users.mysql.password.must_equal "password"
    end

    it "basic test for multi file config" do
      path = File.expand_path("../../base.yml", __FILE__)
      configa = Configa::MagicContainer.new(path)
      mysql = configa.mysql
      dev = configa.development
      dev["mysql"]["adapter"].must_equal mysql.adapter
      dev.mysql.database.must_equal "mysql_dev"
      configa.development.storage.must_equal configa.storage
    end

    it "should raise an error" do
      path = File.expand_path("../../base.yml", __FILE__)
      configa = Configa::MagicContainer.new(path)
      proc{configa.staging}.must_raise Configa::UnknownEnvironment
    end

    it "should raise an error" do
      path = File.expand_path("../../base.yml", __FILE__)
      configa = Configa::MagicContainer.new(path)
      proc{configa.development.sqlite3}.must_raise Configa::UnknownKey
    end
  end

  describe "one file" do
    before do
      path = File.expand_path("../../config.yml", __FILE__)
      @config = Configa.new(path)
    end

    it "should parse simple yml" do
      @config.development.mysql.database.must_equal "mysql_dev"
      @config.development(:mysql).must_equal([{"adapter"=>"mysql", "encoding"=>"utf8", "host"=>"localhost", "username"=>"root", "database"=>"mysql_dev"}])
      @config.development.mysql.username.must_equal "root"
      @config.production.mysql.username.must_equal "admin"
      @config.production.mysql(:username, :database).must_equal ["admin", "mysql_prod"]
      @config.development.mysql.must_equal({"database"=>"mysql_dev", "adapter"=>"mysql", "encoding"=>"utf8", "host"=>"localhost", "username"=>"root"})
    end
  end

  describe "multiple file" do
    before do
      path = File.expand_path("../../base.yml", __FILE__)
      @config = Configa.new(path)
    end

    it "should parse simple yml" do
      @config.development.mysql.database.must_equal "mysql_dev"
      @config.development(:mysql).must_equal([{"adapter"=>"mysql", "encoding"=>"utf8", "host"=>"localhost", "username"=>"root", "database"=>"mysql_dev"}])
      @config.development.mysql.username.must_equal "root"
      @config.production.mysql.username.must_equal "admin"
      @config.production.mysql(:username, :database).must_equal ["admin", "mysql_prod"]
      @config.development.mysql.must_equal({"database"=>"mysql_dev", "adapter"=>"mysql", "encoding"=>"utf8", "host"=>"localhost", "username"=>"root"})
      @config.development.users.tarantool.space.must_equal 1
      @config.development.users.tarantool.port.must_equal 13013
      @config.development.users.tarantool.host.must_equal "212.11.3.1"
    end
  end

  describe "options" do
    it "should work with default env" do
      path = File.expand_path("../../base.yml", __FILE__)
      @config = Configa.new(path, env: :development)
      @config.mysql.username.must_equal "root"
      @config.storage.must_equal "tmp"
      proc{ @config.production.mysql.username }.must_raise Configa::UnknownEnvironment
    end

    it "should return result as a hash" do
      path = File.expand_path("../../config.yml", __FILE__)
      @config = Configa.new(path)
      @config.production.mysql(:username, :database, hash: true).must_equal({ username: "admin", database: "mysql_prod" })
    end
  end
end