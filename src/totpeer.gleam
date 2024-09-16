import bindings/fs
import commands/handlers
import context.{type Context}
import gleam/erlang
import gleam/io
import gleam/result
import sqlight

fn ensure_storage_file() -> Result(String, String) {
  let file_name = "store/base.sqlite3"
  use exists <- result.try(fs.file_exists(file_name))

  case exists {
    True -> Ok(file_name)
    False -> {
      case fs.create_new_file(file_name) {
        Ok(fs.Created) -> Ok(file_name)
        Error(reason) -> Error(reason)
      }
    }
  }
}

fn setup() -> Result(Context, String) {
  use file_name <- result.try(ensure_storage_file())
  use conn <- result.try(
    result.map_error(sqlight.open("file:" <> file_name), fn(x) { x.message }),
  )

  Ok(#(conn))
}

fn run(ctx: Context) {
  let result =
    erlang.get_line("> ")
    |> handlers.parse_input
    |> handlers.process_command(ctx)

  case result {
    Ok(_) -> 0
    Error(error) -> {
      io.println_error(error)
      0
    }
  }

  run(ctx)
}

pub fn main() {
  use context <- result.try(setup())

  run(context)

  Ok(True)
}
