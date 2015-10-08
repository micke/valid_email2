require "spec_helper"

class TestUser < TestModel
  validates :email, email: true
end

class TestUserMX < TestModel
  validates :email, email: { mx: true }
end

class TestUserDisallowDisposable < TestModel
  validates :email, email: { disposable: true }
end

class TestUserDisallowBlacklisted < TestModel
  validates :email, email: { blacklist: true }
end

class TestUserAllowWhitelisted < TestModel
  validates :email, email: { blacklist: true, disposable: true, mx: true, whitelist: true }
end

describe ValidEmail2 do
  describe "basic validation" do
    subject(:user) { TestUser.new(email: "") }

    it "should be valid when email is empty" do
      user.valid?.should be_true
    end

    it "should not be valid when domain is missing" do
      user = TestUser.new(email: "foo")
      user.valid?.should be_false
    end

    it "should be invalid when email is malformed" do
      user = TestUser.new(email: "foo@bar")
      user.valid?.should be_false
    end

    it "should be invalid if Mail::AddressListsParser raises exception" do
      user = TestUser.new(email: "foo@gmail.com")
      Mail::Address.stub(:new).and_raise(Mail::Field::ParseError.new(nil, nil, nil))
      user.valid?.should be_false
    end

    it "shouldn't be valid if the domain constains consecutives dots" do
      user = TestUser.new(email: "foo@bar..com")
      user.valid?.should be_false
    end
  end

  describe "disposable emails" do
    it "should be valid when email is not in the list of disposable emails" do
      user = TestUserDisallowDisposable.new(email: "foo@gmail.com")
      user.valid?.should be_true
    end

    it "should be invalid when email is in the list of disposable emails" do
      user = TestUserDisallowDisposable.new(email: "foo@#{ValidEmail2.disposable_emails.first}")
      user.valid?.should be_false
    end
  end

  describe "blacklisted emails" do
    it "should be valid when email is not in the blacklist" do
      user = TestUserDisallowBlacklisted.new(email: "foo@gmail.com")
      user.valid?.should be_true
    end

    it "should be invalid when email is in the blacklist" do
      user = TestUserDisallowBlacklisted.new(email: "foo@#{ValidEmail2.blacklist.first}")
      user.valid?.should be_false
    end
  end

  describe "mx lookup" do
    it "should be valid if mx records are found" do
      user = TestUserMX.new(email: "foo@gmail.com")
      user.valid?.should be_true
    end

    it "should be invalid if no mx records are found" do
      user = TestUserMX.new(email: "foo@subdomain.gmail.com")
      user.valid?.should be_false
    end
  end

  describe "should alow" do
    it "should be valid if email is in the whitelist" do
      domain = ValidEmail2.whitelist.first
      user = TestUserAllowWhitelisted.new(email: "foo@#{domain}")
    end

    it "should be valid if email is in the blacklist and in the whitelist" do
      domain = (ValidEmail2.blacklist & ValidEmail2.whitelist).first
      user = TestUserAllowWhitelisted.new(email: "foo@#{domain}")
    end

    it "should be valid if email is in the list of disposable emails and in the whitelist" do
      domain = (ValidEmail2.disposable_emails & ValidEmail2.whitelist).first
      user = TestUserAllowWhitelisted.new(email: "foo@#{domain}")
    end

    it "should be valid if mx records are not found and email is in the whitelist" do
      user_mx = TestUserMX.new(email: "foo@#{ValidEmail2.whitelist.first}")
      user_whitelist = TestUserAllowWhitelisted.new(email: "foo@#{ValidEmail2.whitelist.first}")
      user_mx.valid?.should be_false
      user_whitelist.valid?.should be_true
    end
  end
end
