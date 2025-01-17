package compress4cj.utils
public interface InputStreamStatistics {
    func getCompressedCount(): Int64
    func getUncompressedCount(): Int64
}