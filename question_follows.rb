class QuestionFollow

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    question_follow = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil unless question_follows.length > 0
    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        fname, lname
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = ?
    SQL
  end

  def self.most_followed_questions(n)
    QuestionDBConnection.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    GROUP BY
      question_follows.question_id
    ORDER BY
      COUNT(question_follows.user_id)
    LIMIT
      ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def save
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_follows (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        question_follows
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end
