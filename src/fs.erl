-module(fs).

-include_lib("kernel/include/file.hrl").

-export([
    is_file/1,
    create_file/1,
    read_file/1
]).

is_file(File) ->
    case file:read_file_info(File) of
        {ok, {file_info,
            _Size, regular, _Access,
            _Atime, _Mtime, _Ctime,
            _Mode, _Links, _Major_device,
            _Minor_device, _Inode, _Uid, _Gid}}
        -> {ok, true};
        {ok, {file_info,
            _Size, _Type, _Access,
            _Atime, _Mtime, _Ctime,
            _Mode, _Links, _Major_device,
            _Minor_device, _Inode, _Uid, _Gid}}
        -> {ok, false};
        _ -> {ok, false}
    end.

create_file(Path) ->
    case file:open(Path, [exclusive]) of
        {ok, _IoDevice} -> {ok, created};
        {error, Reason} -> {error, Reason}
    end.

read_file(Path) ->
    file:read_file(Path).
