package droplet.droplet
public class RequestTracker {
  private var requests: HashSet<LoadRequest> = HashSet<LoadRequest>()
  // A set of requests that have not completed and are queued to be run again. We use this list to
  // maintain hard references to these requests to ensure that they are not garbage collected
  // before they start running or while they are paused. See #346.
  private var pendingRequests: HashSet<LoadRequest> = HashSet<LoadRequest>();
  private var isPaused: Bool = false;
   func runRequest(request: LoadRequest): Unit {
    requests.put(request);
    if (!isPaused) {
      request.begin();
    } else {
      request.clear();
      pendingRequests.put(request);
    }
  }
  func addRequest(request: LoadRequest): Unit {
    requests.put(request);
  }
   func clearAndRemove(requestcj: LoadRequest): Bool {
    var isOwnedByUs: Bool = requests.remove(requestcj);
    // Avoid short circuiting.
    isOwnedByUs = pendingRequests.remove(requestcj) || isOwnedByUs;
    if (isOwnedByUs) {
      requestcj.clear();
    }
    return isOwnedByUs;
  }
   func getPaused(): Bool {
    return isPaused;
  }
   func pauseRequests(): Unit {
    isPaused = true;
    for (request in Utils.getSnapshot<LoadRequest>(requests)) {
      if (request.isRunning()) {
        // Avoid clearing parts of requests that may have completed (thumbnails) to avoid blinking
        // in the UI, while still making sure that any in progress parts of requests are immediately
        // stopped.
        request.pause();
        pendingRequests.put(request);
      }
    }
  }
   func pauseAllRequests(): Unit {
    isPaused = true;
    for (request in Utils.getSnapshot<LoadRequest>(requests)) {
      // TODO(judds): Failed requests return false from isComplete(). They're still restarted in
      //  resumeRequests, but they're not cleared here. We should probably clear all requests here?
      if (request.isRunning() || request.isComplete()) {
        request.clear();
        pendingRequests.put(request);
      }
    }
  }
   func resumeRequests(): Unit {
    isPaused = false;
    for (request in Utils.getSnapshot<LoadRequest>(requests)) {
      // We don't need to check for cleared here. Any explicit clear by a user will remove the
      // Request from the tracker, so the only way we'd find a cleared request here is if we cleared
      // it. As a result it should be safe for us to resume cleared requests.
      if (!request.isComplete() && !request.isRunning()) {
        request.begin();
      }
    }
    pendingRequests.clear();
  }
   func clearRequests(): Unit {
    for (request in Utils.getSnapshot<LoadRequest>(requests)) {
      // It's unsafe to recycle the Request here because we don't know who might else have a
      // reference to it.
      clearAndRemove(request);
    }
    pendingRequests.clear();
  }
   func restartRequests(): Unit {
    for (request_cj in Utils.getSnapshot<LoadRequest>(requests)) {
      if (!request_cj.isComplete() && !request_cj.isCleared()) {
        request_cj.clear();
        if (!isPaused) {
          request_cj.begin();
        } else {
          pendingRequests.put(request_cj);
        }
      }
    }
  }
  public func toString(): String {
    return "{numRequests=${requests.size}, isPaused=${isPaused}}";
  }
}