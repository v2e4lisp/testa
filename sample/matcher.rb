include Testa

test("matcher#ok pass") {
  ok { true }
}

test("matcher#ok fail when falsy value returned") {
  ok { false }
}

test("matcher#error pass 1") {
  class MyError < StandardError; end
  error { raise MyError, "error message!" }
}

test("matcher#error fail when no error occur") {
  error { true }
}

test("matcher#error pass 2") {
  class MyError < StandardError; end
  error(MyError) { raise MyError, "error message!" }
}

test("matcher#error fail when error classes do not match") {
  class MyError < StandardError; end
  error(StandardError) { raise MyError, "error message!" }
}

test("matcher#error pass 3") {
  class MyError < StandardError; end
  error(/message/) { raise MyError, "error message!" }
}

test("matcher#error fail when error messages do not match") {
  class MyError < StandardError; end
  error(/wenjun/) { raise MyError, "error message!" }
}

test("matcher#error pass 4") {
  class MyError < StandardError; end
  error(MyError, /message/) { raise MyError, "error message!" }
}

test("matcher#error fail when error messages/classes do not match") {
  class MyError < StandardError; end
  error(StandardError, /message/) { raise MyError, "error message!" }
}

Testa.run
