require "spec_helper"

describe ApiController do

  describe "#configurations" do
    subject { get :configurations, format: :json }

    let(:config_json) { { configurations: { accepting_applications: true } } }

    it "returns the configurations" do
      subject
      expect(response).to be_success
      expect(response.body).to eq config_json.to_json
    end
  end
end
