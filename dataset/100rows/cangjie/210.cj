package ohos_app_cangjie_entry
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
@Entry
@Component
class BugCodeList2Page {
    func render() {
        Scroll() {
            Column {
                MarkdownComponent(mdStr: mdStr)
            }
        }
        .scrollable(ScrollDirection.Vertical)
    }
    let mdStr: String = """
```clojure_language []
(defn sum [a b]
  (+ a b))
; 使用示例
(println (sum 10 20)) ; 输出结果将是 30
```
```css_extras []
li:nth-child(3) {
  color: red;
}
```
```clojure []
(defn sum [a b]
  (+ a b))
; 使用示例
(println (sum 10 20)) ; 输出结果将是 30
```
"""
}