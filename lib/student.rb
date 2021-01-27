require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id

  end

  def self.create_table
    #creates db
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    #deletes students table
    sql = <<-SQL 
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    #updates attributes if id is found or creates row if id isnt found
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    #creates new instance from passed in values & adds to db
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    #creates instance from db row
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(name, grade, id)
  end

  def self.find_by_name(name)
    #find first row in db where name = name
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map {|row| new_from_db(row)}.first
  end

  def update
    #updates both name & grade when id is passed
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  
end
