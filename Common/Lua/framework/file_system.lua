local file_system = class("file_system", function(self)
end)

function file_system.exsit_file(path)
    -- ELOG("file_system.exsit_file not implement")
    return IsFileExist(path)
end

function file_system.get_file_path(path)
--     ELOG("file_system.get_file_path not implement")
    return GetFilePath(path)
end

function file_system.get_file_time(path)
    -- ELOG("file_system.get_file_time not implement")
    return FileWriteTime(path)
end

function file_system.get_files(path, recursive)
    -- ELOG("file_system.get_files not implement")
    return GetFolderFiles(path)
end
 