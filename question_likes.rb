

class QuestionLike
  attr_accessor :question_like

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_id(id)
    question_like = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    return nil unless question_like.length > 0
    QuestionLike.new(question_lke.first)
  end

  def self.find_by_user(user_id)
    question_like = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        user_id = ?
    SQL

    return nil unless question_like.length > 0
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*)
    FROM
      question_likes
    WHERE
      question_id = ?
    SQL

    num_likes.first.values[0]
  end

  def self.liked_questions_for_user_id(user_id)
    titles = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.title
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_id = ?
    SQL

    titles.map { |hash| hash.values[0] }
  end

  def self.most_liked_questions(n)
    QuestionDBConnection.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    GROUP BY
      question_likes.question_id
    ORDER BY
      COUNT(question_likes.user_id)
    LIMIT
      ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def save
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_likes (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_likes
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end
end
