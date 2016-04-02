require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
  username { "user#{sn}" }
  email { "#{sn}@example.com" }
  # Attributes here
end

User.blueprint(:visitor) { state { 'visitor' } }
User.blueprint(:applicant) { state { 'applicant' } }
User.blueprint(:attendee) { state { 'attendee' } }
User.blueprint(:application_reviewer) { state { 'application_reviewer' } }

Application.blueprint do
end

Application.blueprint(:with_user) { user { User.make!(:applicant) } }

Vote.blueprint do
  value { true }
end

Comment.blueprint do
  # Attributes here
end
