CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL,
  title TEXT,
  body TEXT,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
--
INSERT INTO
  users (fname, lname)
VALUES
  ('Kimmy', 'Allgeier'),
  ('Liz', 'Houle');

INSERT INTO
  questions (author_id, title, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Kimmy'), 'Wut up with CSS?',
  'I do not understand it'),
  ((SELECT id FROM users WHERE fname = 'Liz'), 'Ferry',
  'Why is the ferry always late?');

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Wut up with CSS?'), NULL,
  (SELECT id FROM users WHERE fname = 'Liz'), 'Just google everything');
