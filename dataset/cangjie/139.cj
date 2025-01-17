package okhttpprofiler
from std import log.*
from std import io.*
from std import collection.*
from net import http.Header
from okhttp import okhttp.*
public class LogDataTransfer <: DataTransfer{
    private static let LOG_LENGTH = 4000
    private static let SLOW_DOWN_PARTS_AFTER = 20
    private static let BODY_BUFFER_SIZE = 1024 * 1024 * 10
    private static let LOG_PREFIX = "OKPRFL"
    private static let DELIMITER = "_"
    private static let HEADER_DELIMITER = ':'
    private static let SPACE = ' '
    private static let KEY_TAG = "TAG"
    private static let KEY_VALUE = "VALUE"
    private static let KEY_PARTS_COUNT = "PARTS_COUNT"
    private static let CONTENT_TYPE = "Content-Type"
    private static let CONTENT_LENGTH = "Content-Length"
    public func sendRequest(id: String, request: Request): Unit {
        fastLog(id, MessageType.REQUEST_METHOD("RQM"), request.getMethod());
        let url = request.getUrl().toString();
        fastLog(id, MessageType.REQUEST_URL("RQU"),url);
        let nowSjc = Time.now().unixNano()
        fastLog(id, MessageType.REQUEST_TIME("RQT"), Time.now().toString());
        let copy = request.newBuilder().build();
        match(copy.getBody()){
             case Some(v) => doSomeThingRequestBody(v,id)
             case _ => ()
        }
        let headers = request.getHeaders()
        for(header in headers){
            let name: String = header[0]
            let nameUpper = name.toAsciiUpper();
            let conentTypeUpper = CONTENT_TYPE.toAsciiUpper();
            let conentLengthUpper = CONTENT_LENGTH.toAsciiUpper();
            if (conentTypeUpper.equals(nameUpper) || conentLengthUpper.equals(nameUpper)) {
                continue
            }
            let arrayList: ArrayList<String> = header[1]
            if(arrayList.size>0){
                if(arrayList.size == 1){
                    fastLog(id, MessageType.REQUEST_HEADER("RQH"), name + HEADER_DELIMITER + SPACE + arrayList.get(0).getOrThrow());
                }else{
                    var strBuilder = StringBuilder();
                    for(str in arrayList){
                        strBuilder.append(str).append(",")
                    }
                    fastLog(id, MessageType.REQUEST_HEADER("RQH"), name + HEADER_DELIMITER + SPACE + strBuilder.toString());
                }
            }
        }
    }
      public func sendResponse(id: String, response: Response): Unit {
        let optionBody: Option<ResponseBody> = response.getBody()
        match(optionBody){
              case Some(v) => doSomeThingResponseBody(v,id)
              case _ => ()
        }
        logWithHandler(id, MessageType.RESPONSE_STATUS("RSS"), response.getCode().toString(), 0);
        let headers = response.getHeaders()
        for(header in headers){
                let name: String = header[0]
                let arrayList : ArrayList<String> = header[1]
                if(arrayList.size > 0){
                    if(arrayList.size == 1){
                        logWithHandler(id, MessageType.RESPONSE_HEADER("RSH"), name + HEADER_DELIMITER + arrayList.get(0).getOrThrow(), 0);
                    }else{
                        var strBuilder = StringBuilder();
                        for(str in arrayList){
                            strBuilder.append(str).append(",")
                        }
                        logWithHandler(id, MessageType.RESPONSE_HEADER("RSH"), name + HEADER_DELIMITER + strBuilder.toString(), 0);
                    }
                }
            }
    }
        public func sendException(id: String, ex: Exception): Unit {
            logWithHandler(id, MessageType.RESPONSE_ERROR("REE"), ex.message, 0);
        }
        public func sendDuration(id: String, duration: Int64): Unit {
            logWithHandler(id, MessageType.RESPONSE_TIME("RST"), duration.toString(), 0);
            logWithHandler(id, MessageType.RESPONSE_END("RSD"), "-->", 0);
        }
        private func fastLog(id: String, mType: MessageType, message: String): Unit {
            let tag = LOG_PREFIX + DELIMITER + id + DELIMITER + mType.getValue();
            printLog(tag,message)
        }
        private func printLog(tag: String, message: String): Unit {
            let logger: SimpleLogger = SimpleLogger()
             //var s = File("../stdout8.log", AccessMode.Write, OpenMode.Append)
             //logger.setOutput(s)
            logger.log(LogLevel.TRACE, tag+SPACE+SPACE+message)
            logger.flush()
            //s.close()
        }
        private func doSomeThingResponseBody(body : ResponseBody,id: String): Unit {
            let source = body.getString() //Array<UInt8>
            let sourceSize = source.size
            var strResponse = ""
            if(sourceSize<BODY_BUFFER_SIZE){
                strResponse = source.substring(0,sourceSize)
            }else{
                strResponse = source.substring(0,BODY_BUFFER_SIZE)
            }
            largeLog(id, MessageType.RESPONSE_BODY("RSB"), strResponse);
        }
        private func logWithHandler(id: String, mType: MessageType, message: String, partsCount: Int64): Unit {
                 let tag = LOG_PREFIX + DELIMITER + id + DELIMITER + mType.getValue();
                 let logger: SimpleLogger = SimpleLogger()
                 //var s = File("../stdout8.log", AccessMode.Write, OpenMode.Append)
                 //logger.setOutput(s)
                 logger.log(LogLevel.TRACE, tag+SPACE+SPACE+message+SPACE+partsCount.toString())
                 logger.flush()
                 //s.close()
            }
    private func doSomeThingRequestBody(body : RequestBody,id: String): Unit {
         let mediaType = match(body.contentType()) {
            case Some(m) => "${m}"
            case None => ""
         }
         let contentLength = body.getContentLength()
         if (contentLength != -1) {
                fastLog(id, MessageType.REQUEST_HEADER("RQH"), CONTENT_LENGTH + HEADER_DELIMITER + SPACE + contentLength.toString());
         }
        fastLog(id,MessageType.REQUEST_HEADER("RQH"),CONTENT_TYPE + HEADER_DELIMITER + SPACE + mediaType)
         let inputStream = body.get()
         let bas = inputStream as ByteArrayStream
         match(bas){
            case Some(v) => doSomeThingRequestBodyLog(v,id)
            case _ => ()
         }
    }
    private func doSomeThingRequestBodyLog(bas :ByteArrayStream, id: String): Unit{
         largeLog(id, MessageType. REQUEST_BODY("RQB"),String.fromUtf8(bas.readToEnd()));
    }
    private func largeLog(id: String, mType: MessageType, content: String): Unit {
        let contentLength = content.size
        if (contentLength > LOG_LENGTH) {
            let parts = contentLength / LOG_LENGTH
            for (i in 0..parts) {
                let start = i * LOG_LENGTH
                var end = start + LOG_LENGTH
                if (end > contentLength) {
                    let printLength = contentLength+LOG_LENGTH-end
                    logWithHandler(id, mType, content.substring(start, printLength), parts);
                }else{
                    let printLength  = LOG_LENGTH
                    logWithHandler(id, mType, content.substring(start, LOG_LENGTH), parts);
                }
            }
        } else {
            logWithHandler(id, mType, content, 0);
        }
    }
}