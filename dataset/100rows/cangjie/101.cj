package openai_chat
import std.console.Console
import std.collection.ArrayList

func cli_chat(env_info: EnvInfo, stream!: Bool) {
  println("\n欢迎使用AI聊天机器人，输入exit或者quit退出，输入clear清空历史记录");
  var history: ArrayList<(String, String)> = ArrayList<(String, String)>();
  while (true) {
    print("Input: ");
    var prompt: String = "";
    match(Console.stdIn.readln()) {
      case Some(str1: String) => prompt=str1;
      case None => continue;
    }
    if (prompt == "exit" || prompt == "exit()") {
      break;
    }
    if (prompt == "clear") {
      history.clear();
      println("Output: 已清理历史对话信息。");
      continue;
    }
    print("ChatBox: ")
    let response_option: Option<String> = if (stream) {
      stream_chat(prompt, env_info, history);
    } else {
      chat(prompt, env_info, history);
    }
    match (response_option) {
      case Some(response: String) => 
        if (stream) {
           println("") ;
        } else {
            println("${response}");
        }
        history.append((prompt, response));
      case None => println("遇到错误，即将退出"); break;
    }
  }
}


main(args: Array<String>): Int64 {
  let env_info = load_env_info();
  var stream: Bool = false;
  if (args.size == 1) {
    if (args[0] == "--stream") {
      stream = true;
    } else {
      println("Warning! you can only use `--stream` to use stream for response.")
    }
  }
  cli_chat(env_info, stream: stream);
  return 0
}