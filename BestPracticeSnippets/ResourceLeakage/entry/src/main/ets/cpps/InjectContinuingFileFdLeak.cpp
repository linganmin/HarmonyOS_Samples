// [Start inject_continuing_file_fd_leak]
void InjectContinuingFileFdLeak(string path)
{
     mode_t fileMode = 0644;
     int fd = open(path, O_CREAT | O_RDWR, fileMode);
     if (fd < 0) {
        return;
     }
     if (XXX) {
         close(fd);
         return;
     }
     close(fd);
}
// [End inject_continuing_file_fd_leak]