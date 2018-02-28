

class Reply
  attr_accessor :question_id, :parent_id, :user_id, :body


  def self.find_by_parent(parent_id)
    reply = QuestionDBConnection.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map{ |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    QuestionDBConnection.instance.execute(<<-SQL, @user_id)
    SELECT
      fname, lname
    FROM
      users
    JOIN
      replies ON replies.user_id = users.id
    WHERE
      users.id = @user_id
    SQL
  end

  def question
    QuestionDBConnection.instance.execute(<<-SQL, @question_id)
    SELECT
      title, questions.body
    FROM
      questions
    JOIN
      replies ON replies.question_id = questions.id
    WHERE
      questions.id = @question_id
    SQL
  end

  def parent_reply
    QuestionDBConnection.instance.execute(<<-SQL, @parent_id)
    SELECT
      body
    FROM
      replies
    WHERE
      id = @parent_id
    SQL
  end

  def child_replies
    QuestionDBConnection.instance.execute(<<-SQL, @id)
    SELECT
      body
    FROM
      replies
    WHERE
      parent_id = @id
    SQL
  end

  def save
    if @id
      update
    else
      QuestionDBConnection.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @body)
        INSERT INTO
          replies (question_id, parent_id, user_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionDBConnection.instance.last_insert_row_id
    end
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @body, @id)
      UPDATE
        replies
      SET
        question_id = ?, parent_id = ?, user_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end
end
