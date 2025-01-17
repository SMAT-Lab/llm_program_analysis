/*
题目描述
给你一个字符串数组 words 和一个字符 separator ，请你按 separator 拆分 words 中的每个字符串。
返回一个由拆分后的新字符串组成的字符串数组，不包括空字符串 。
- separator 用于决定拆分发生的位置，但它不包含在结果字符串中。
- 拆分可能形成两个以上的字符串。
- 结果字符串必须保持初始相同的先后顺序。

仓颉语言团队 刘俊杰 2024.10.24
*/

import std.collection.*

func split(words: Array<String>, separator: Rune): Array<String> {
    words |> map { text =>
        text.split(String(separator), removeEmpty: true)
    } |> flatten |> collectArray
}

main() {
    let words = ["one.two.three", ".four.five", "six.", "seven"]
    let separator = r'.'
    let result = split(words, separator)
    println(result)
}