include Testa

test("failed") {
  ok { 1 == 2 }
}

test("passed") {
  ok { 1 == 1 }
}

test "todo"

test("error") {
  undeinfed_vars
}

Testa.run
