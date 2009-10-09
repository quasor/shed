# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_shed_session',
  :secret      => '05b50e57dd885d7fbdaafee2824502ed125403ae32b212dd6f2179145af3c89459d0e5d393de55c25ab8cdbcbfabecf4b0401c066604fcd1bf68da9bfab17cc5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
