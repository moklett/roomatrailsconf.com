# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_roomatrailsconf_session',
  :secret      => '03f5618d6fe37548e4788468b41df7f9040cc0eb4464646f7ce5ced380c826a17da947a6d0f978a5d6465291d4ba7f5b55c1350367c8ca65e99f76c0d0d894c1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
