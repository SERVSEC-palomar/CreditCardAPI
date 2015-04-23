configure :development do
  set :database, 'sqlite3:db/dev.db'
  set :show_exceptions, true
end
