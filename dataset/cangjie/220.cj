package ohos_app_cangjie_entry
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
@Entry
@Component
class Leetcode5Page {
    func render() {
        Scroll() {
            Column {
                MarkdownComponent(mdStr: mdStr, markdownConfiguration: setConfig())
            }
        }
        // 设置滚动方法
        .scrollable(ScrollDirection.Vertical)
    }
    func setConfig(): MarkdownConfiguration {
        let markdownConfigurationBuilder: MarkdownConfigurationBuilder = MarkdownConfiguration.emptyBuilder()
        markdownConfigurationBuilder.setMarkdownTheme(setMarkdownTheme())
        return markdownConfigurationBuilder.build()
    }
    func setMarkdownTheme(): MarkdownTheme {
        let markdownTheme: MarkdownTheme = MarkdownTheme.emptyBuilder()
                                            // 设置一级二级标题下划线高度
                                            .setHeadingBreakHeight(0.0)
                                            // 软换行
                                            .setIsLineBreak(true)
                                            .build()
        return markdownTheme
    }
    let mdStr: String = ###"
# heading 1
## heading 2
### heading 3
#### heading 4
##### heading 5
###### heading 6
通过 = 来实现 H1
=
通过 - 来实现 H2
-
####### 最小只支持 h6
######不兼容无空格接触
转译 \#
"###
}