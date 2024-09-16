// A small binding for erlang lib POT
// Ref: https://github.com/yuce/pot

pub type Token =
  String

pub type Secret =
  String

@external(erlang, "pot", "totp")
pub fn totp(s: Secret) -> Token
