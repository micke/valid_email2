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

describe ValidEmail2 do
  describe "basic validation" do
    subject(:user) { TestUser.new(email: "") }

    it "should be valid when email is empty" do
      user.valid?.should be_true
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

  describe "mx lookup" do
    it "should be valid if mx records are found" do
      user = TestUserMX.new(email: "foo@gmail.com")
      user.valid?.should be_true
    end

    it "should be invalid if no mx records are found" do
      user = TestUserMX.new(email: "foo@subdomain.gmail.com")
      user.valid?.should be_false
    end

    it "should be invalid if ResolvTimeout is thrown" do
      Resolv::DNS.any_instance.stub(:getresources).and_raise(Resolv::ResolvTimeout)
      user = TestUserMX.new(email: "foo@gmail.com")
      user.valid?.should be_false
    end
  end
end
