pub type FileError {
  Enoent
}

pub fn describe_file_error(error: FileError) -> String {
  case error {
    Enoent -> "There is no such file or directory"
  }
}

@external(erlang, "fs", "is_file")
fn is_file(path: String) -> Result(Bool, FileError)

pub type FileCreation {
  Created
}

@external(erlang, "fs", "create_file")
fn create_file(path: String) -> Result(FileCreation, FileError)

@external(erlang, "fs", "read_file")
fn read_file(path: String) -> Result(String, FileError)

pub fn file_exists(path: String) -> Result(Bool, String) {
  case is_file(path) {
    Ok(result) -> Ok(result)
    Error(reason) -> Error(describe_file_error(reason))
  }
}

pub fn create_new_file(path: String) -> Result(FileCreation, String) {
  case create_file(path) {
    Ok(x) -> Ok(x)
    Error(reason) -> Error(describe_file_error(reason))
  }
}

pub fn get_file(path: String) -> Result(String, String) {
  case read_file(path) {
    Ok(data) -> Ok(data)
    Error(reason) -> describe_file_error(reason) |> Error
  }
}
