require "spec_helper"

class TestUser < TestModel
  validates :email, 'valid_email_2/email': true
end

class TestUserSubaddressing < TestModel
  validates :email, 'valid_email_2/email': {disallow_subaddressing: true}
end

class TestUserMX < TestModel
  validates :email, 'valid_email_2/email': { mx: true }
end

class TestUserDisallowDisposable < TestModel
  validates :email, 'valid_email_2/email': { disposable: true }
end

class TestUserDisallowBlacklisted < TestModel
  validates :email, 'valid_email_2/email': { blacklist: true }
end

describe ValidEmail2 do
  describe "basic validation" do
    subject(:user) { TestUser.new(email: "") }

    it "should not be valid email is valid" do
      user = TestUser.new(email: "foo@bar123.com")
      expect(user.valid?).to be_truthy
    end

    it "should be valid when email is empty" do
      expect(user.valid?).to be_truthy
    end

    it "should not be valid when domain is missing" do
      user = TestUser.new(email: "foo@.com")
      expect(user.valid?).to be_falsey
    end

    it "should be invalid when domain includes invalid characters" do
      %w(+ _ !).each do |invalid_character|
        user = TestUser.new(email: "foo@google#{invalid_character}yahoo.com")
        expect(user.valid?).to be_falsey
      end
    end

    it "should be invalid when email is malformed" do
      user = TestUser.new(email: "foo@bar")
      expect(user.valid?).to be_falsey
    end

    it "should be invalid if Mail::AddressListsParser raises exception" do
      user = TestUser.new(email: "foo@gmail.com")
      expect(Mail::Address).to receive(:new).and_raise(Mail::Field::ParseError.new(nil, nil, nil))
      expect(user.valid?).to be_falsey
    end

    it "shouldn't be valid if the domain constains consecutives dots" do
      user = TestUser.new(email: "foo@bar..com")
      expect(user.valid?).to be_falsey
    end
  end

  describe "disposable emails" do
    it "should be valid when the domain is not in the list of disposable email providers" do
      user = TestUserDisallowDisposable.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "should be invalid when domain is in the list of disposable email providers" do
      user = TestUserDisallowDisposable.new(email: "foo@#{ValidEmail2.disposable_emails.first}")
      expect(user.valid?).to be_falsey
    end

    it "should be invalid when domain is a subdomain of a disposable domain" do
      user = TestUserDisallowDisposable.new(email: "foo@bar.#{ValidEmail2.disposable_emails.first}")
      expect(user.valid?).to be_falsey
    end

    it "should allow example.com that is common in lists of disposable email providers" do
      user = TestUserDisallowDisposable.new(email: "foo@example.com")
      expect(user.valid?).to be_truthy
    end
  end

  describe "blacklisted emails" do
    it "should be valid when email is not in the blacklist" do
      user = TestUserDisallowBlacklisted.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "should be invalid when email is in the blacklist" do
      user = TestUserDisallowBlacklisted.new(email: "foo@#{ValidEmail2.blacklist.first}")
      expect(user.valid?).to be_falsey
    end
  end

  describe "mx lookup" do
    it "should be valid if mx records are found" do
      user = TestUserMX.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "should be valid if A records are found" do
      user = TestUserMX.new(email: "foo@ghs.google.com")
      expect(user.valid?).to be_truthy
    end

    it "should be invalid if no mx records are found" do
      user = TestUserMX.new(email: "foo@subdomain.gmail.com")
      expect(user.valid?).to be_falsey
    end
  end

  describe "emoticons emails" do
    it "should be invalid if email contains emoticon" do
      email = ValidEmail2::Address.new("foo🙈@gmail.com")
      expect(email.valid?).to be_falsy
    end
  end

  describe "subaddressed emails" do

    describe "::Address::DEFAULT_RECIPIENT_DELIMITER" do
      it "should be recipient delimiter ('+')" do
        expect(ValidEmail2::Address::DEFAULT_RECIPIENT_DELIMITER).to eq('+')
      end
    end

    describe "::Address#subaddressed?" do
      it "should be true when address local part contains a recipient delimiter ('+')" do
        email = ValidEmail2::Address.new("foo+1@gmail.com")
        expect(email.subaddressed?).to be_truthy
      end

      it "should be false when address local part contains a recipient delimiter ('+')" do
        email = ValidEmail2::Address.new("foo@gmail.com")
        expect(email.subaddressed?).to be_falsey
      end
    end

    describe "user validation" do
      context "subaddressing is allowed (default)" do
        it "should be valid when address local part does not contain a recipient delimiter ('+')" do
          user = TestUser.new(email: "foo@gmail.com")
          expect(user.valid?).to be_truthy
        end

        it "should be valid when address local part contains a recipient delimiter ('+')" do
          user = TestUser.new(email: "foo+1@gmail.com")
          expect(user.valid?).to be_truthy
        end
      end

      context "subaddressing is forbidden" do
        it "should be valid when address local part does not contain a recipient delimiter ('+')" do
          user = TestUserSubaddressing.new(email: "foo@gmail.com")
          expect(user.valid?).to be_truthy
        end

        it "should be invalid when address local part contains a recipient delimiter ('+')" do
          user = TestUserSubaddressing.new(email: "foo+1@gmail.com")
          expect(user.valid?).to be_falsey
        end
      end
    end

  end
end
