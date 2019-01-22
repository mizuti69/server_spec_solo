#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.dirname(__FILE__)
$oj_dir = File.dirname(File.expand_path(File.dirname(__FILE__)))
%w(lib ext).each do |dir|
  $: << File.join($oj_dir, dir)
end

require 'oj'
require 'tracer'

#Tracer.on

class MyParser
  attr_accessor :enum

  def initialize
    @io = StringIO.new
    @writer = Oj::StreamWriter.new(@io)

    json_string = Oj.dump({ records: 1.upto(2).map{|i| { id: i, name: "record_#{i}" }} }, mode: :strict)
    @test_json = StringIO.new(json_string)

    @enum = Enumerator.new do |yielder|
      @yielder = yielder
      Oj.sc_parse(self, @test_json)
    end
  end

  # Stream parsing methods
  def hash_start
    @writer.push_object
  end

  def hash_end
    @writer.pop unless @io.eof
  end

  def hash_key(key)
    @writer.push_key(key)
  end

  def hash_set(h, key, value)
    @writer.push_value(value)
  end

  def array_start
    @writer.push_array
  end

  def array_end
    @writer.pop
  end

  def array_append(a, value)
    yield_data
  end

  def add_value(value);end

  def yield_data
    @writer.pop_all
    @yielder << @io.string
    @io.reopen("")
    array_start
  end
end

#puts MyParser.new.enum.to_a

puts "------------"

MyError = Class.new(StandardError)

MyParser.new.enum.each.with_index do |r, i|
  puts "========="
  raise MyError.new('hello')
  #raise StopIteration if i == 0
  #break if i >= 4
end

#{"records":[{"id":1,"name":"record_1"},{"id":2,"name":"record_2"},{"id":3,"name":"record_3"},{"id":4,"name":"record_4"},{"id":5,"name":"record_5"},{"id":6,"name":"record_6"},{"id":7,"name":"record_7"},{"id":8,"name":"record_8"},{"id":9,"name":"record_9"},{"id":10,"name":"record_10"},{"id":11,"name":"record_11"},{"id":12,"name":"record_12"},{"id":13,"name":"record_13"},{"id":14,"name":"record_14"},{"id":15,"name":"record_15"},{"id":16,"name":"record_16"},{"id":17,"name":"record_17"},{"id":18,"name":"record_18"},{"id":19,"name":"record_19"},{"id":20,"name":"record_20"},{"id":21,"name":"record_21"},{"id":22,"name":"record_22"},{"id":23,"name":"record_23"},{"id":24,"name":"record_24"},{"id":25,"name":"record_25"}]}
