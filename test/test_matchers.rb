require 'minitest/autorun'

class TestMatchers <  MiniTest::Unit::TestCase
  include Testa::Matcher
  class MyError < StandardError; end

  def test_fail_raise_failure
    assert_raises Testa::Failure do
      fail!
    end
  end

  def test_ok_not_raise_failure_for_truthy_value
    assert(ok { true })
    assert(ok { 0 })
    assert(ok { "" })
  end

  def test_ok_raise_failure_for_falsy_value
    assert_raises Testa::Failure do
      ok { false }
    end

    assert_raises Testa::Failure do
      ok { nil }
    end
  end

  def test_error_raise_failure_when_no_error_in_given_block
    assert_raises Testa::Failure do
      error { nil }
    end

    assert_raises Testa::Failure do
      error { false }
    end

    assert_raises Testa::Failure do
      error { true }
    end
  end

  def test_error_raise_failure_when_expected_error_class_not_match
    assert_raises Testa::Failure do
      error(MyError) { raise }
    end
  end

  def test_error_raise_failure_when_expected_error_message_not_match
    assert_raises Testa::Failure do
      error("hello") { raise "world" }
    end
  end

  def test_error_raise_failure_when_expected_error_message_or_class_not_match
    assert_raises Testa::Failure do
      error(MyError, "hello") { raise "hello" }
    end

    assert_raises Testa::Failure do
      error(MyError, "hello") { raise MyError }
    end

    assert_raises Testa::Failure do
      error(MyError, "hello") { raise MyError, "world" }
    end
  end

end
