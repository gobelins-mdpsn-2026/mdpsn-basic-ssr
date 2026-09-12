require "sequel"

# One connection pool for the whole app. DATABASE_URL looks like
# postgres://user:password@host:5432/dbname
DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

# Create the table on first boot. Real apps use migrations; one table is enough here.
DB.create_table?(:todos) do
  primary_key :id
  String :title, null: false
  TrueClass :done, null: false, default: false
  DateTime :created_at, null: false
end
