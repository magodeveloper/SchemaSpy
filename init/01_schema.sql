-- Sample schema for SchemaSpy demonstration
-- This file is executed automatically when the PostgreSQL container starts

CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    username    VARCHAR(100) NOT NULL UNIQUE,
    email       VARCHAR(255) NOT NULL UNIQUE,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Registered application users';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.username IS 'Unique username chosen by the user';
COMMENT ON COLUMN users.email IS 'User email address';
COMMENT ON COLUMN users.created_at IS 'Timestamp when the user was created';
COMMENT ON COLUMN users.updated_at IS 'Timestamp when the user was last updated';

CREATE TABLE IF NOT EXISTS roles (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL UNIQUE,
    description TEXT
);

COMMENT ON TABLE roles IS 'Application roles for access control';
COMMENT ON COLUMN roles.id IS 'Unique identifier for the role';
COMMENT ON COLUMN roles.name IS 'Role name (e.g. admin, editor, viewer)';
COMMENT ON COLUMN roles.description IS 'Human-readable description of the role';

CREATE TABLE IF NOT EXISTS user_roles (
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id     INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

COMMENT ON TABLE user_roles IS 'Many-to-many mapping of users to roles';
COMMENT ON COLUMN user_roles.user_id IS 'Reference to the user';
COMMENT ON COLUMN user_roles.role_id IS 'Reference to the role';
COMMENT ON COLUMN user_roles.assigned_at IS 'When the role was assigned to the user';

CREATE TABLE IF NOT EXISTS posts (
    id          SERIAL PRIMARY KEY,
    author_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    body        TEXT,
    published   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE posts IS 'User-authored posts or articles';
COMMENT ON COLUMN posts.id IS 'Unique identifier for the post';
COMMENT ON COLUMN posts.author_id IS 'The user who authored the post';
COMMENT ON COLUMN posts.title IS 'Post title';
COMMENT ON COLUMN posts.body IS 'Post body text';
COMMENT ON COLUMN posts.published IS 'Whether the post is publicly visible';
COMMENT ON COLUMN posts.created_at IS 'Timestamp when the post was created';
COMMENT ON COLUMN posts.updated_at IS 'Timestamp when the post was last updated';

CREATE TABLE IF NOT EXISTS comments (
    id          SERIAL PRIMARY KEY,
    post_id     INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body        TEXT NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE comments IS 'User comments on posts';
COMMENT ON COLUMN comments.id IS 'Unique identifier for the comment';
COMMENT ON COLUMN comments.post_id IS 'The post this comment belongs to';
COMMENT ON COLUMN comments.author_id IS 'The user who wrote the comment';
COMMENT ON COLUMN comments.body IS 'The comment text';
COMMENT ON COLUMN comments.created_at IS 'Timestamp when the comment was created';

-- Seed some default roles
INSERT INTO roles (name, description) VALUES
    ('admin',  'Full access to all resources'),
    ('editor', 'Can create and edit posts'),
    ('viewer', 'Read-only access')
ON CONFLICT (name) DO NOTHING;
