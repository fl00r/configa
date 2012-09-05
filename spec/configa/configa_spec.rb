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
    end

    it "basic test for multi file config" do
      path = File.expand_path("../../base.yml", __FILE__)
      configa = Configa::MagicContainer.new(path)
      mysql = configa.mysql
      dev = configa.development
      dev["mysql"]["adapter"].must_equal mysql.adapter
      dev.mysql.database.must_equal "mysql_dev"
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
    end
  end
end