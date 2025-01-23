package download4cj
public interface DownloadMonitor {
    func taskStart(task:DownloadTask):Unit
    func taskDownloadFromBreakpoint(task:DownloadTask,info:BreakpointInfo):Unit
    func taskDownloadFromBeginning(task:DownloadTask,info:BreakpointInfo,cause:ResumeFailedCause):Unit
    func taskEnd(task:DownloadTask,cause:EndCause,realCause:Exception):Unit
}