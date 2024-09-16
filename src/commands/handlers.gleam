import bindings/fs
import context.{type Context}
import gleam/dynamic
import gleam/erlang.{type GetLineError}
import gleam/io
import gleam/result
import gleam/string
import sqlight

pub type Command {
  AddAccountCmd(cmd: String, account_name: String, secret: String)
  FindAccountCmd(cmd: String, account_name: String)
  UpdateDbCmd(cmd: String)
  Noop
}

pub fn parse_input(input: Result(String, GetLineError)) -> Command {
  let input = case input {
    Ok(str) -> str
    Error(_) -> {
      io.println_error("There was an error processing your input")
      ""
    }
  }

  case string.split(string.trim(input), " ") {
    ["add", account, secret] -> {
      AddAccountCmd("add", account, secret)
    }
    ["update"] -> {
      UpdateDbCmd("update")
    }
    ["find", account] -> FindAccountCmd("find", account)
    [any, ..] -> {
      io.print_error("Command " <> any <> " is not supported")
      Noop
    }
    [] -> Noop
  }
}

pub fn process_command(command: Command, ctx: Context) {
  let #(conn) = ctx
  let cat_decoder = dynamic.tuple2(dynamic.string, dynamic.string)
  case command {
    UpdateDbCmd(_) -> {
      use base_sql <- result.try(fs.get_file("store/schema/base.sql"))

      case sqlight.exec(base_sql, conn) {
        Ok(_) -> Ok(0)
        Error(err) -> Error(err.message)
      }
    }
    AddAccountCmd(_, account, secret) -> {
      case
        sqlight.query(
          "insert into accounts (account, secret) values (?, ?)",
          conn,
          [sqlight.text(account), sqlight.text(secret)],
          cat_decoder,
        )
      {
        Ok(_) -> Ok(0)
        Error(err) -> Error(err.message)
      }
    }
    FindAccountCmd(_, account) -> {
      case
        sqlight.query(
          "select account, secret from accounts where account = ?",
          conn,
          [sqlight.text(account)],
          cat_decoder,
        )
      {
        Ok(x) -> {
          io.debug(x)
          Ok(0)
        }
        Error(err) -> Error(err.message)
      }
    }
    Noop -> {
      Ok(0)
    }
  }
}
