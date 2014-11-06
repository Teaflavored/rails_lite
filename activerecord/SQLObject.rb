require_relative 'db_connection'
require_relative 'SQLObject'
require_relative "searcheable"
require_relative "associable"
require_relative "validations"
require 'byebug'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
class SQLObject 
  extend Validations
  extend Searchable
  extend Associatable
  def self.columns

    #all_cats returns array with first array being column names
    all_cats = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL

    all_cats.first.map(&:to_sym)
  end

  def self.finalize!
    define_method "attributes" do
      @attributes ||= {}
    end

    columns.each do |column|
      define_method "#{column}" do
        self.attributes[column]
      end

      define_method "#{column}=" do |value|
        self.attributes[column] = value
      end
    end
  end

  def initialize(params = {})
    params.each do |column_name, value|
      raise "unknown attribute '#{column_name}'" unless self.class.columns.include?(column_name.to_sym)
      self.send("#{column_name}=", value)
    end
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.pluralize(:en)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.all
    query = <<-SQL
    SELECT
      *
    FROM
      #{table_name}
    SQL

    parse_all(DBConnection.execute(query))
  end

  def self.parse_all(results)

    results.map do |hash|
      self.new(hash)
    end

  end

  def self.find(id)
    query = <<-SQL
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    LIMIT
      1
    SQL
    hash = DBConnection.execute(query, id).first
    return nil if hash.nil?
    self.new(hash)
  end

  def self.find_by(attribute_hash)
    column = attribute_hash.keys.first 
    value = attribute_hash.values.first
    query = <<-SQL
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.#{column} = ?
    LIMIT
      1
    SQL
    hash = DBConnection.execute(query, value).first
    return nil if hash.nil?
    self.new(hash)
  end

  def attributes
    self.class.attributes
  end

  def attribute_values
    values = attributes.values
    if attributes.keys.include?(:id) && attributes.keys.first != :id
      id = values.pop
      [id] + values
    else
      values
    end
  end

  def insert
    col_names = self.attributes.keys.map(&:to_s)
    value_names = Array.new(col_names.count) { '?' }.join(",")

    query = <<-SQL
    INSERT INTO
      #{self.class.table_name} (#{col_names.join(",")})
    VALUES
      (#{value_names})
    SQL
    DBConnection.execute(query, *self.attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_rows = self.class.columns.map { |column| "#{column} = ?" }.join(",")
    query = <<-SQL
      UPDATE
        #{self.class.table_name}
      SET
        #{set_rows}
      WHERE
        #{self.class.table_name}.id = ?
    SQL

    DBConnection.execute(query, *self.attribute_values, self.id.to_i)
  end

  def save
    # unless self.class.validate_methods.nil?
    #   @errors = {}
    #   self.class.validate_methods.each do |method|
    #     self.send(method)
    #   end
    #   raise error_msg.to_s unless @errors.keys.empty?
    # # validate :name_cant_be_empty
    #   self.class.validate_methods_clear
    # end

    if self.id.nil?
      insert
    else
      update
    end
  end


  def error_msg
    array_of_msg = []
    @errors.each do |key, value|
      array_of_msg << "#{key} #{value}"
    end

    array_of_msg
  end

  def self.includes(assoc_name)
    #combine current object with assoc_name
    table_name = assoc_name.to_s.downcase.pluralize
    #foreign_key = "#{table_name}.#{self.table_name.singularize}_id"
    primary_key = "#{self.table_name}.id"
    foreign_key = "#{table_name}.owner_id"


    query = <<-SQL
    SELECT
      #{self.table_name}.*, #{table_name}.*
    FROM
      #{self.table_name}
    LEFT OUTER JOIN
      #{table_name}
    ON
      #{foreign_key} = #{primary_key}
    SQL

    p DBConnection.execute(query)

  end


  def self.joins(sql)
    query = <<-SQL
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    #{sql}
    SQL
    arr_of_hash_obj = DBConnection.execute(query)
    arr_of_hash_obj.map do |hash_obj|
      self.new(hash_obj)
    end
  end
end