require 'sqlite3'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id.nil?
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.new_from_db(row)
    attributes = { id: row[0], name: row[1], breed: row[2] }
    Dog.new(attributes)
  end

  def self.all
    sql = "SELECT * FROM dogs"
    rows = DB[:conn].execute(sql)
    rows.map { |row| Dog.new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row) if row
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id).first
    Dog.new_from_db(row) if row
  end
end

# Connect to the SQLite database
DB = {
  conn: SQLite3::Database.new('dog.db')
}

Dog.create_table