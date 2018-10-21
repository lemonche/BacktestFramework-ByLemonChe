function [ files ] = scanDir(root_dir,filename_patent)

files={};
if root_dir(end)~='\'
 root_dir=[root_dir,'\'];
end
fileList=dir(root_dir);  %扩展名
n=length(fileList);
cntpic=0;
for i=1:n
    if strcmp(fileList(i).name,'.')==1||strcmp(fileList(i).name,'..')==1
        continue;
    else
        if ~fileList(i).isdir % 如果不是目录则跳过
            filename = fileList(i).name;
            if contains(filename,filename_patent)    % 如果文件名满足要求的模式则返回结果
                full_name=[root_dir,filename];
                cntpic=cntpic+1;
                files(cntpic,:)={full_name};
            end
        else
            files=[files;scanDir([root_dir,fileList(i).name],filename_patent)];
        end
    end
end

end