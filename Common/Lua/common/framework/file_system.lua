local file_system = class("file_system", function(self)
end)

local fs = NFFileSystemModule --NFFileSystemModule.ins

function file_system.exsit_file(path)
    -- ELOG("file_system.exsit_file not implement")
    return fs.IsFileExist(path)
end

function file_system.get_file_path(path)
--     ELOG("file_system.get_file_path not implement")
    return fs.GetFilePath(path)
end

function file_system.get_file_time(path)
    -- ELOG("file_system.get_file_time not implement")
    return fs.FileWriteTime(path)
end

function file_system.get_files(path, recursive)
    -- ELOG("file_system.get_files not implement")
    return fs.GetFolderFiles(path, recursive)
    -- return NFFileSystemModule.GetFolderFiles(path, recursive)
end

function file_system.read_file(path)
    -- ELOG("file_system.get_folders not implement")
    return fs.ReadFile(path)
end

function file_system.write_file(path, content)
    -- ELOG("file_system.write_file not implement")
    return fs.WriteFile(path, content)
end


 