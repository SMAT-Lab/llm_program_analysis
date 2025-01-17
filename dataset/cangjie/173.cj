package ohos_app_cangjie_entry
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
@Entry
@Component
class ARItalicPage {
    func render() {
        Scroll() {
            Column {
                MarkdownComponent(mdStr: mdStr)
            }
        }
        // 设置滚动方法
        .scrollable(ScrollDirection.Vertical)
    }
    let mdStr: String = """
### 斜体1
### *斜体标题*
### 斜体2
### _斜体标题_
### 斜体3
*斜体文本*
### 斜体4
_斜体文本_
### 斜体5
# Italicized text is the *cat's meow*.
### 斜体6
# Italicized text is the _cat's meow_.
### 斜体7
# A*cat*meow
### 斜体8
# A_at_meow
### 斜体9
Italicized text is the *cat's meow*.
### 斜体10
Italicized text is the _cat's meow_.
### 斜体11
A*cat*meow
### 斜体12
A_cat_meow
"""
}