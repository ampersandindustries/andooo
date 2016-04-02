shared_examples "deny non-application reviewers" do |folks|
  folks.each do |folk|
    it "should deny non-application reviewers" do
      login_as(folk)
      subject
      expect(response).to redirect_to :root
    end
  end
end

shared_examples "allow application reviewers" do |folks|
  folks.each do |folk|
    it "should allow application reviewers" do
      login_as(folk)
      subject
      expect(response).to be_success
    end
  end
end

shared_examples "allow applicants" do |folks|
  folks.each do |folk|
    it "should allow applicants" do
      login_as(folk)
      subject
      expect(response).to be_success
    end
  end
end
