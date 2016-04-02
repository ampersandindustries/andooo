FactoryGirl.define do


  factory :user do
    name { "#{Faker::Name.first_name.gsub("'", "")} #{Faker::Name.last_name.gsub("'", "")}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}

    factory :application_reviewer do
      state "application_reviewer"
    end

    factory :applicant do
      state "applicant"
    end

    factory :approved_applicant do
      state "applicant"
    end

    factory :attendee do
      state "attendee"
    end

    factory :admin do
      is_admin true
      state "application_reviewer"
    end
  end

  factory :vote do
    association :user, factory: :application_reviewer
    application
    value false
  end

  factory :application do
    association :user, factory: :applicant
    state "submitted"
    agreement_coc true
    agreement_attendance true
    agreement_deadline true

    factory :unsubmitted_application do
      state "started"
    end

    factory :approvable_application do
      after(:create) do |application, _|
        create_list(:vote, Application::MINIMUM_YES, application: application, value: true)
      end
    end

    factory :rejectable_application do
      after(:create) do |application, _|
        create_list(:vote, Application::MAXIMUM_NO + 1, application: application, value: false)
      end
    end

    factory :approved_application do
      association :user, factory: :approved_applicant

      state "approved"
      processed_at Time.zone.now
    end

    factory :confirmed_application do
      association :user, factory: :attendee

      state "confirmed"
      confirmed_at Time.zone.now
    end
  end

  factory :authentication do
    uid { rand(100000...999999).to_s }
    provider { "github" }
    association :user, factory: :attendee
  end
end
