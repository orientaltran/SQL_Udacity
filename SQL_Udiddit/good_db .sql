/*-------------SQL PROJECT2------------------------*/
/*---------Part II: Create the DDL for your new schema---------*/
DROP TABLE IF EXISTS 
  "Users",
  "Topics",
  "Posts",
  "Comments",
  "Votes";
/*-------------a.Allow new users to register----*/
CREATE TABLE "Users" (
    id                    SERIAL PRIMARY KEY,
    username              VARCHAR(25) NOT NULL,
    created               TIMESTAMP,
    created_by            VARCHAR(25),
    updated               TIMESTAMP,
    last_login            TIMESTAMP,
    updated_by            VARCHAR(25),
    CONSTRAINT            "PK_Users" UNIQUE ("username"),
    CONSTRAINT            "Not_Empty_UserName" CHECK (LENGTH(TRIM("username")) > 0)
);
    
/*---------b.Allow registered users to create new topics:------*/  
CREATE TABLE "Topics" (
    id                    SERIAL PRIMARY KEY,
    name                  VARCHAR(30) NOT NULL,
    description           VARCHAR(500),
    CONSTRAINT            "PK_Topics" UNIQUE ("name"),
    created               TIMESTAMP,
    created_by            VARCHAR(25),
    updated               TIMESTAMP,
    updated_by            VARCHAR(25),
    CONSTRAINT            "Not_Empty_Topic_Name" CHECK (LENGTH(TRIM("name")) > 0)
);

/*-----------c.Allow registered users to create new posts on existing topics------*/
CREATE TABLE "Posts" (
    id                    SERIAL PRIMARY KEY,
    title                 VARCHAR(100) NOT NULL,
    url                   VARCHAR(400),
    text_content          TEXT,
    topic_id              INTEGER REFERENCES "Topics" ON DELETE CASCADE,
    user_id               INTEGER REFERENCES "Users" ON DELETE SET NULL,
    created               TIMESTAMP,
    created_by            VARCHAR(25),
    updated               TIMESTAMP,
    updated_by            VARCHAR(25),
    CONSTRAINT            "Not_Empty_Title" CHECK (LENGTH(TRIM("title")) > 0),
    CONSTRAINT            "URL_or_Text" CHECK (
      (LENGTH(TRIM("url")) > 0 AND LENGTH(TRIM("text_content")) = 0) OR
      (LENGTH(TRIM("url")) = 0 AND LENGTH(TRIM("text_content")) > 0)
    )
);
CREATE INDEX ON "Posts" ("url" VARCHAR_PATTERN_OPS);


/*-----------d.Allow registered users to comment on existing posts------*/
CREATE TABLE "Comments" (
    id                  SERIAL PRIMARY KEY,
    text_content        TEXT NOT NULL,
    post_id             INTEGER REFERENCES "Posts" ON DELETE CASCADE,
    user_id             INTEGER REFERENCES "Users" ON DELETE SET NULL,
    parent_comment_id   INTEGER REFERENCES "Comments" ON DELETE CASCADE,
    created             TIMESTAMP,
    created_by          VARCHAR(25),
    updated             TIMESTAMP,
    updated_by          VARCHAR(25),
    CONSTRAINT          "Not_Empty_Text_Content" CHECK(LENGTH(TRIM("text_content")) > 0)
);

/*-----------e.	Make sure that a given user can only vote once on a given post:------*/
CREATE TABLE "Votes" (
    id                  SERIAL PRIMARY KEY,
    user_id             INTEGER REFERENCES "users" ON DELETE SET NULL,
    post_id             INTEGER,
    vote                SMALLINT NOT NULL,
    created             TIMESTAMP,
    created_by          VARCHAR(25),
    updated             TIMESTAMP,
    updated_by          VARCHAR(25),
    CONSTRAINT          "Valid_Votes" CHECK ( "vote" IN (-1, 1)),
    CONSTRAINT          "PK_Users_Votes" UNIQUE (user_id, post_id)
);

/**************************INSERT DATA**************************/
/* 1. Migrate data to "users" table I used "UNION" to remove all duplicate. */
INSERT INTO "Users" ( "username" )
   SELECT
       username
   FROM
       bad_posts
   UNION
   SELECT
       regexp_split_to_table(upvotes, ',') AS username
   FROM
       bad_posts
   UNION
   SELECT
       regexp_split_to_table(downvotes, ',') AS username
   FROM
       bad_posts
   UNION
   SELECT
       ( username ) AS username
   FROM
       bad_comments;
       
/* 2. Migrate data to "topics" table "DISTINCT" used to remove duplicate */
INSERT INTO "Topics" ( "name" )
   SELECT DISTINCT
       topic
   FROM
       bad_posts;
 
/* 3. Migrate data to "posts" table */
INSERT INTO "Posts" (
   "user_id",
   "topic_id",
   "title",
   "url",
   "text_content"
)
   SELECT
       u.id,
       t.id,
       left(bp.title, 100),
       bp.url,
       bp.text_content
   FROM
       bad_posts as bp
       INNER JOIN Users as u ON bp.username = u.username
       INNER JOIN Topics as t ON bp.topic = t.name;
 
/* Step 4 - Migrate data to "comments" table */
INSERT INTO "Comments" (
   "post_id",
   "user_id",
   "text_content"
)
   SELECT
       p.id,
       u.id,
       bp.text_content
   FROM
       bad_comments as bp
       JOIN Users as u ON bp.username = u.username
       JOIN Posts as p ON p.id = bp.post_id;
            
/* Step 5 - Migrate data to "Votes" table */
 ---------------------Insert Votes with type = 1
INSERT INTO "Votes" (
   "post_id",
   "user_id",
   "vote"
)
   SELECT
       v1.id,
       u.id,
       1 AS vote_up
   FROM
       (
           SELECT
               id,
               regexp_split_to_table(upvotes, ',') AS upvote_users
           FROM
               bad_posts
       ) v1
       JOIN Users as u ON u.username = v1.upvote_users;
 ---------------------Insert Votes with type = -1
INSERT INTO "Votes" (
   "post_id",
   "user_id",
   "vote"
)
   SELECT
       v2.id,
       u.id,
       - 1 AS vote_down
   FROM
       (
           SELECT
               id,
               regexp_split_to_table(downvotes, ',') AS downvote_users
           FROM
               bad_posts
       ) v2
       JOIN Users as u ON u.username = v2.downvote_users;
/***END SCIPT**/