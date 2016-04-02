require 'spec_helper'

describe Comment do
  it 'should validate presence of user id' do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:user_id)
  end

  it 'should validate presence of application id' do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:application_id)
  end

  it 'should validate presence of body' do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:body)
  end

  it 'should not be valid for visitor' do
    comment = Comment.new
    comment.user = User.make!(:visitor)
    expect(comment.tap(&:valid?)).to have_at_least(1).errors_on(:user)
  end

  it 'should not be valid for applicant' do
    comment = Comment.new(user: User.make!(:applicant))
    expect(comment.tap(&:valid?)).to have_at_least(1).errors_on(:user)
  end

  it 'should not be valid for attendee' do
    comment = Comment.new(user: User.make!(:attendee))
    expect(comment.tap(&:valid?)).to have_at_least(1).errors_on(:user)
  end

  it 'should be valid for application reviewer' do
    comment = Comment.new
    comment.user = User.make!(:application_reviewer)
    expect(comment.tap(&:valid?)).to have(0).errors_on(:user)
  end

  it 'should be saved for application reviewer' do
    comment = Comment.new(body: 'hello')
    comment.application = Application.make!(:with_user)
    comment.user = User.make!(:application_reviewer)
    expect(comment.save).to be_truthy
  end
end
