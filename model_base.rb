class ModelBase
  def initialize
  end

  def self.find_by_id(id, table)
    result = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL

    return nil unless result.length > 0
    result
  end

  def self.all(table)
    data = QuestionDBConnection.instance.execute("SELECT * FROM #{table}")
    # data.map { |datum| User.new(datum) }
  end

  def save(table)
    variables = self.instance_variables[1..-1].join(",")
    string_vars = self.instance_variables[1..-1].map(&:to_s).join(", ")

    if @id
      update(table)
    else
      QuestionDBConnection.instance.execute(<<-SQL, string_vars)
        INSERT INTO
          #{table} (#{string_vars})
        VALUES
          (?, ?)
      SQL
      @id = QuestionDBConnection.instance.last_insert_row_id
    end
  end

  # def update(table)
  #   variables = self.instance_variables
  #   raise "#{self} not in database" unless @id
  #   QuestionDBConnection.instance.execute(<<-SQL, #{variables.join(", ")})
  #     UPDATE
  #       #{table}
  #     SET
  #       fname = ?, lname = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
end
