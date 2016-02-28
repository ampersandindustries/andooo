FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name.gsub("'", "")} #{Faker::Name.last_name.gsub("'", "")}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}

    factory :member do
      state "member"

      factory :mature_member do
        after(:create) do |user|
          user.application.processed_at = 14.days.ago
          user.application.save!
        end
      end

      factory :setup_complete_member do
        sequence(:email_for_google) { |n| "googleemail#{n}@example.com" }
        dues_pledge [10, 25, 50].sample
        stripe_customer_id "123abc"
        setup_complete true
      end
    end

    factory :key_member do
      state 'key_member'
    end

    factory :voting_member do
      state "voting_member"
      voting_policy_agreement true
    end

    factory :applicant do
      state "applicant"
    end

    factory :admin do
      is_admin true
      state "voting_member"
    end
  end

  factory :vote do
    association :user, factory: :voting_member
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
      state "approved"
      processed_at Time.zone.now
    end
  end

  factory :authentication do
    uid { rand(100000...999999).to_s }
    provider { "github" }
    association :user, factory: :member
  end
end
