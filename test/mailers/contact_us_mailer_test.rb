require "test_helper"

class ContactUsMailerTest < ActionMailer::TestCase
  test "send_reply" do
    mail = ContactUsMailer.send_reply
    assert_equal "Send reply", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
