include Testa

class User < Struct.new(:name); end

Testa.define_hook(:init_user) {
  @user = User.new("default-user")
}

Testa.define_hook(:change_user_name) {
  @user.name = "changed"
}

test("user have a default name", :before => :init_user) {
  ok { @user.name == "default-user" }
}

test("user have a default name", :before => [:init_user, :change_user_name]) {
  ok { @user.name == "default-user" }
}

test("[NO SETUP] user have a default name ") {
  ok { @user.name == "default-user" }
}

with(:before => :init_user) {

  test("user object") {
    ok { @user }
  }

  test("user has a name") {
    ok { @user.name }
  }

}

Testa.run
