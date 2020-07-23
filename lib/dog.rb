class Dog
  attr_accessor :id, :name, :breed

  def initialize(p = {})
    @id, @name, @breed = p[:id], p[:name], p[:breed]
  end

  #Instance methods for main ORM actions
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs
          (name, breed)
        VALUES
          (?, ?);
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
    end

    self
  end

  #Class methods for main ORM actions
  def self.create(p = {})
    new(name: p[:name], breed: p[:breed]).save
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_or_create_by(p = {})
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL

    row = DB[:conn].execute(sql, p[:name], p[:breed])

    if !row.empty?
      new_from_db(row[0])
    else
      create(name: p[:name], breed: p[:breed])
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs
      (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end
end