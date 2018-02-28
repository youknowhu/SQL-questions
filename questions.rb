require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :author_id

  def self.find_by_title(title)
    question = QuestionDBConnection.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL

    return nil unless question.length > 0
    Question.new(question.first)
  end

  def self.find_by_author(fname, lname)
    author = User.find_by_name(fname, lname)
    raise "#{name} not found in DB" unless author

    question = QuestionDBConnection.instance.execute(<<-SQL, author.id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
  end

  def self.find_by_author_id(author_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    return nil unless questions.length > 0
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @author_id = options['author_id']
    @body = options['body']
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def author
    QuestionDBConnection.instance.execute(<<-SQL, @author_id)
      SELECT DISTINCT
        fname, lname
      FROM
        users
      JOIN
        questions ON users.id = questions.author_id
      WHERE
        users.id = @author_id
    SQL
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def replies
    Reply.find_by_user_id(@id)
  end

  def save
    if @id
      update
    else
      QuestionDBConnection.instance.execute(<<-SQL, @author_id, @title, @body)
        INSERT INTO
          questions (author_id, title, body)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionDBConnection.instance.last_insert_row_id
    end
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @author_id, @title, @body, @id)
      UPDATE
        questions
      SET
        author_id = ?, title = ?, body = ?
      WHERE
        id = ?
    SQL
  end
end
