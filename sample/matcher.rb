require '../lib/testa'
Testa.autorun

class MyError < StandardError; end

test("matcher#ok pass") {
  ok { true }
}

test("matcher#ok fail when falsy value returned") {
  ok { false }
}

test("matcher#error pass 1") {
  error { raise MyError, "error message!" }
}

test("matcher#error fail when no error occur") {
  error { true }
}

test("matcher#error pass 2") {
  error(MyError) { raise MyError, "error message!" }
}

test("matcher#error fail when error classes do not match") {
  error(StandardError) { raise MyError, "error message!" }
}

test("matcher#error pass 3") {
  error(/message/) { raise MyError, "error message!" }
}

test("matcher#error fail when error messages do not match") {
  error(/wenjun/) { raise MyError, "error message!" }
}

test("matcher#error pass 4") {
  error(MyError, /message/) { raise MyError, "error message!" }
}

test("matcher#error fail when error messages/classes do not match") {
  error(StandardError, /message/) { raise MyError, "error message!" }
}


class User < Struct.new(:name); end

def setup_user
  @user = User.new("default-user")
end

test("user have a default name") {
  setup_user
  ok { @user.name == "default-user" }
}

test("[NO SETUP] user have a default name ") {
  ok { @user.name == "default-user" }
}
