package tokenizer

main(): Int64 {
    let vocab_path = "./download/Qwen2-0.5B-Instruct/tokenizer.json";
    let system_prompt = "You are a helpful assistant.";
    let tokenizer = HuggingfaceTokenizer()
    tokenizer.load_vocab(file_path: vocab_path);
    // -- test1 --- //
    println("===== test1 ===== ");
    let raw_text = "世界你好，hello world!";
    let encode_tokens1 = tokenizer.encode(raw_text);
    println("encode_tokens: ${encode_tokens1}");
    let decode_str1 = tokenizer.decode(encode_tokens1, skip_special_tokens: false);
    println("deocode_str: ${decode_str1}");
    println("===== ===== ===== ");

    // -- test2 -- //
    println("===== test2 ===== ");
    let raw_text2 = raw_text + "<|im_end|>";
    let encode_tokens2 = tokenizer.encode(raw_text2);
    println("encode_tokens: ${encode_tokens2}");
    let decode_str2 = tokenizer.decode(encode_tokens2, skip_special_tokens: false);
    println("deocode_str(with special)    : ${decode_str2}");
    let decode_str3 = tokenizer.decode(encode_tokens2, skip_special_tokens: true);
    println("deocode_str(without special) : ${decode_str3}");
    println("===== ===== ===== ");

    // --- test3 --- //
    println("===== test3 ===== ");
    let messages = ArrayList<Message>([
        Message(RoleType.System, system_prompt),
        Message(RoleType.User, raw_text)
    ])
    let new_text = tokenizer.apply_chat_template(messages, add_generation_prompt: true);
    println("new_text:\n ${new_text}");
    return 0
}