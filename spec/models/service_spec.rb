require 'spec_helper'

describe Service do
  describe "Validations/Associations" do
    it { should validate_presence_of :uid }
    it { should validate_presence_of :provider }
    it { should validate_presence_of :user }

    describe "#user" do
      it { should belong_to :user }
    end
  end
  describe "#find_from_hash" do
    it "Should find the provider and UID when it's already in database" do
      fb = FACEBOOK_HASH_DATA
      service = Factory.create(:service, :provider => fb['provider'], :uid => fb['uid'])
      Service.find_from_hash(fb).should == service
    end

    it "Should return nil if the provider/uid isn't in the DB" do
      Service.find_from_hash(FACEBOOK_HASH_DATA).should == nil
    end
  end

  describe "#create_from_hash" do
    context "When an user exists" do
      fb = FACEBOOK_HASH_DATA
      user = Factory.create(:user)
      subject { Service.create_from_hash(fb, user) }
      its(:uid) { should == fb['uid'] }
      its(:provider) { should == fb['provider'] }
      its(:user) { should == user }
    end
    context "When the user doesn't exists yet" do
      fb = FACEBOOK_HASH_DATA
      subject { Service.create_from_hash(fb) }
      its(:uid) { should == fb['uid'] }
      its(:provider) { should == fb['provider'] }
      its(:user) { should_not == nil }
    end
  end
end