require_relative 'questions'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :fname, :lname

  def self.find_by_name(fname)
    user = QuestionDBConnection.instance.execute(<<-SQL, fname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
    SQL

    return nil unless user.length > 0
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  # def save
  #   if @id
  #     update
  #   else
  #     QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname)
  #       INSERT INTO
  #         users (fname, lname)
  #       VALUES
  #         (?, ?)
  #     SQL
  #     @id = QuestionDBConnection.instance.last_insert_row_id
  #   end
  # end

  def average_karma
    QuestionDBConnection.instance.execute(<<-SQL, @id)
    SELECT
      CAST(COUNT(question_likes.user_id) AS FLOAT)/COUNT(DISTINCT(questions.id))
    FROM
      questions
    LEFT OUTER JOIN
      question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.author_id = ?
    SQL
  end

  # def update
  #   raise "#{self} not in database" unless @id
  #   QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
  #     UPDATE
  #       users
  #     SET
  #       fname = ?, lname = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
end
