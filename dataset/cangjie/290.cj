package ohos_app_cangjie_entry
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
@Entry
@Component
class AROrderedList1Page {
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
        markdownConfigurationBuilder.setImageCallback(imageCallback)
        markdownConfigurationBuilder.setVideoCallback(videoCallback)
        markdownConfigurationBuilder.setVideoImageCallback(videoImageCallback)
        markdownConfigurationBuilder.setLinkCallback(linkCallback)
        markdownConfigurationBuilder.setCodeCopyCallback(codeCopyCallback)
        markdownConfigurationBuilder.setCodeFullScreenCallback(codeFullScreenCallback)
        markdownConfigurationBuilder.setMarkdownTheme(setMarkdownTheme())
        return markdownConfigurationBuilder.build()
    }
    func setMarkdownTheme(): MarkdownTheme {
        let markdownTheme: MarkdownTheme = MarkdownTheme.emptyBuilder()
                                            // 视频默认占位图
                                            .setVideoImage(@r(app.media.video_image))
                                            // 视频播放按钮默认图
                                            .setPlayCircleFillIcon(@r(app.media.play_circle_fill))
                                            // 代码复制按钮默认图
                                            .setCodeCopyIcon(@r(app.media.icon_copy))
                                            // 代码全屏按钮默认图
                                            .setCodeFullScreenIcon(@r(app.media.full_screen))
                                            // 图片banner默认占位图
                                            .setBannerImage(@r(app.media.video_image))
                                            // 图片默认占位图
                                            .setImageResource(@r(app.media.video_image))
                                            .build()
        return markdownTheme
    }
    func imageCallback(url: String) {
        PromptAction.showToast(message: url)
        AppLog.info("------------------------LinkCallback:${url}")
    }
    func videoCallback(url: String) {
        PromptAction.showToast(message: url)
        AppLog.info("------------------------videoCallback:${url}")
    }
    func videoImageCallback(url: String, videoImageCallbackCallback: (String) -> Unit) {
        if (url == "562986b1-46d8-48ef-bac6-82685bcedcd8") {
            videoImageCallbackCallback("https://pic.leetcode-cn.com/1614477066-YeEeWg-file_1614477068523")
        } else {
            videoImageCallbackCallback("https://pic.leetcode-cn.com/1614477067-itHyLr-file_1614477069388")
        }
        AppLog.info("------------------------videoImageCallback:${url}")
    }
    func linkCallback(url: String) {
        PromptAction.showToast(message: url)
        AppLog.info("------------------------LinkCallback:${url}")
    }
    func codeCopyCallback(url: String) {
        PromptAction.showToast(message: url)
        AppLog.info("------------------------codeCopyCallback:${url}")
    }
    func codeFullScreenCallback(url: String, infos: ?String) {
        PromptAction.showToast(message: "${url}${infos}")
        AppLog.info("------------------------codeFullScreenCallback:${url}")
        AppLog.info("------------------------codeFullScreenCallback:${infos}")
    }
    let mdStr: String = """
### 有序列表1(序号顺序正确,段落)
1. 有序列表1-1
2. 有序列表1-2
3. 有序列表1-3
4. 有序列表1-4
5. 有序列表1-5
6. 有序列表1-6
### 有序列表2(序号顺序错误,段落)
1. 有序列表2-1
6. 有序列表2-2
2. 有序列表2-3
5. 有序列表2-4
3. 有序列表2-5
4. 有序列表2-6
### 有序列表3(超长内容,段落)
1. 有序列表3-1。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
6. 有序列表3-2。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
2. 有序列表3-3。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
5. 有序列表3-4。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
3. 有序列表3-5。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
4. 有序列表3-6。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
### 有序列表4(序号顺序正确,标题)
1. # 有序列表4-1
2. # 有序列表4-2
3. # 有序列表4-3
4. # 有序列表4-4
5. # 有序列表4-5
6. # 有序列表4-6
### 有序列表5(序号顺序错误,标题)
1. ## 有序列表5-1
6. ## 有序列表5-2
2. ## 有序列表5-3
5. ## 有序列表5-4
3. ## 有序列表5-5
4. ## 有序列表5-6
### 有序列表6(超长内容,标题)
1. #### 有序列表6-1。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
1. #### 有序列表6-2。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
1. #### 有序列表6-3。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
1. #### 有序列表6-4。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
1. #### 有序列表6-5。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
1. #### 有序列表6-6。超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度超级长度
### 有序列表7(嵌套缩进代码块)
1.  Open the file.
2.  Find the following code block on line 21:
        <html>
        <head>
            <title>Test</title>
        </head>
3.  Update the title to match the name of your website.
### 有序列表8(嵌套围栏代码块)
1.  Open the file.
2.  Find the following code block on line 21:
    ```html
    <html>
    <head>
        <title>Test</title>
    </head>
    ```
3.  Update the title to match the name of your website.
### 有序列表9(嵌套表格)
1.  Open the file.
2.  Find the following code block on line 21:
    | abc | def |
    | --- | --- |
    | abc | def |
    | abc | def |
3.  Update the title to match the name of your website.
### 有序列表10(嵌套图片Banner)
1.  Open the file.
2.  Find the following code block on line 21:
    <![图片名称1](https://pic.leetcode-cn.com/1614477066-YeEeWg-file_1614477068523),![图片名称2](https://pic.leetcode-cn.com/1614477066-byZRdJ-file_1614477068721),![图片名称3](https://pic.leetcode-cn.com/1614477066-olRayu-file_1614477068738)>
3.  Update the title to match the name of your website.
### 有序列表11(嵌套围栏代码列表)
1.  Open the file.
2.  Find the following code block on line 21:
    ```java [solution1-Java 答案]
    public class Main {
        public static void main(String[] args) {
            System.out.print(\"你好力扣\");
        }
    }
    ```
    ```python [solution1-Python 答案]
    print \"你好力扣\"
    ```
3.  Update the title to match the name of your website.
### 有序列表12(嵌套视频)
1.  Open the file.
2.  Find the following code block on line 21:
    ![力扣视频](562986b1-46d8-48ef-bac6-82685bcedcd8)
3.  Update the title to match the name of your website.
### 有序列表13(嵌套图片)
1.  Open the file.
2.  Find the following code block on line 21:
    ![图片名称1](https://pic.leetcode-cn.com/1614477066-YeEeWg-file_1614477068523)
3.  Update the title to match the name of your website.
### 有序列表14(嵌套无序列表)
1.  Open the file.
2.  Find the following code block on line 21:
    *  Open the file.
    *  Find the following code block on line 21:
    *  Update the title to match the name of your website.
3.  Update the title to match the name of your website.
### 有序列表15(嵌套有序列表)
1.  Open the file.
2.  Find the following code block on line 21:
    1.  Open the file.
    2.  Find the following code block on line 21:
    3.  Update the title to match the name of your website.
3.  Update the title to match the name of your website.
### 有序列表16(嵌套任务列表)
1.  Open the file.
2.  Find the following code block on line 21:
    * [ ] Open the file.
    * [ ] Find the following code block on line 21:
    * [ ] Update the title to match the name of your website.
3.  Update the title to match the name of your website.
### 有序列表17(嵌套块引用)
1.  Open the file.
2.  Find the following code block on line 21:
    >  Open the file.
    >
    >  Find the following code block on line 21:
    >
    >  Update the title to match the name of your website.
3.  Update the title to match the name of your website.
### 有序列表18(嵌套标题)
1.  Open the file.
2.  Find the following code block on line 21:
    ### 11111111
3.  Update the title to match the name of your website.
### 有序列表19(嵌套段落)
1.  Open the file.
2.  Find the following code block on line 21:
    11111111
3.  Update the title to match the name of your website.
### 有序列表20(嵌套图片style)
1.  Open the file.
2.  Find the following code block on line 21:
     ![image.png](https://pic.lingkou.xyz/1697707152-SaQbJz-image.png){:width=100}{:height=200}{:align="left"}{:style="border-radius: 50px"}
3.  Update the title to match the name of your website.
"""
}