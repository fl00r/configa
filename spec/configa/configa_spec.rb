# encoding: utf-8
require 'spec_helper'

describe Configa do
  describe "one file" do
    before do
      path = File.expand_path("../../config.yml", __FILE__)
      @config = Configa.new(path)
    end

    it "should parse simple yml" do
      @config.development.mysql.database.must_equal "mysql_dev"
      @config.development.mysql.username.must_equal "root"
      @config.production.mysql.username.must_equal "admin"
      @config.production.mysql(:username, :database).must_equal ["admin", "mysql_prod"]
      @config.development.mysql.must_equal({"database"=>"mysql_dev", "adapter"=>"mysql", "encoding"=>"utf8", "host"=>"localhost", "username"=>"root"})
    end
  end
end