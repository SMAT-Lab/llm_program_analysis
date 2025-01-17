package editor_kit
from ohos import base.*
from ohos import concurrency.*
from ohos import component.*
from ohos import measure.*
from ohos import pasteboard.*
from ohos import state_manage.*
from ohos import state_macro_manage.*
from std import collection.*
from std import math.*
from std import sync.*
from std import time.*
import editor_kit.widget.*
import editor_kit.editorKitUtils.*
import treesitter.*
import editor_kit.utils.*
@Component
public class EditorKit {
    var editorKitController: EditorKitController = EditorKitController(width: 0.0, height: 0.0)
    // 初始化 richEditor 控制器
    let controller = RichEditorController()
    // 初始化 scroll 控制器
    private let scroller = Scroller()
    // editorKit 组件高度
    @State var subHeight: Float64 = 0.0
    // editorKit 组件宽度
    @State var subWidth: Float64 = 0.0
    // 行号区域宽度
    @State var textCompWidth = 0.0
    // 行号区域高度
    @State var textCompHeight = 0.0
    // 记录文本真实占据行数信息
    @State var lineHeightArray: ObservedArrayList<Int64> = ObservedArrayList<Int64>()
    @State var valid = false
    @State var suggestionList: ObservedArrayList<String> = ObservedArrayList<String>()
    @State var backgroundColor: Color = Color(0XFFFFFF)
    @State var gutterColor: Color = Color(0x272823)
    @State var gutterTextColor: Color = Color(0x5B5A4F)
    @State var gutterDividerColor: Color = Color(0x5B5A4F)
    private var deleteoffset: Int32 = 0
    private var insertValue: String = ""
    private var insertOffset: Int32 = 0
    private var start: Int32 = 0
    private var end: Int32 = 0
    private var suffix = ""
    var scrollY: Float64 = 0.0
    @State var popX = 0.0
    @State var popY = 0.0
    private let deleteTimer = Box<?Timer>(Option<Timer>.None)
    private var deleteLength: Int32 = 0
    private let scrollTimer = Box<?Timer>(Option<Timer>.None)
    private let pasteTimer = Box<?Timer>(Option<Timer>.None)
    private var isDelete = false
    private var isPaste = false
    var scrollOffset: Float64 = 0.0
    // 获取长度是 num，元素为 0 的数组
    private func createArray(num: Int64) {
        return ArrayList<Int64>(Array(num, item: 0))
    }
    protected func onAppear() {
        editorKitController.bindEditorKit(this)
    }
    public func render() {
        Scroll(this.scroller) {
            Flex(FlexParams(alignItems: ItemAlign.Start)) {
                if (valid) {
                    List() {
                        ForEach(suggestionList, itemGeneratorFunc: {item: String, index: Int64 =>
                            ListItem(){
                                Text(item)
                                    .fontSize(14.vp)
                                    .width(100.percent)
                                    .maxLines(1)
                                    .textOverflow(TextOverflow.Ellipsis)
                                    .textAlign(TextAlign.Start)
                                    .onClick({ event =>
                                        editorKitController.insertSuggestWord(item)
                                    })
                            }.editable(false)
                        })
                    }
                        .position(x: popX, y: popY)
                        .constraintSize(maxHeight: 340.px)
                        .padding(8.0)
                        .width(subWidth / 2.0)
                        .zIndex(999)
                        .shadow(radius: 30)
                        .borderRadius(10)
                        .backgroundColor(Color.WHITE)
                        .divider(strokeWidth: 6.vp, color: Color.WHITE)
                        .listDirection(Axis.Vertical)
                        .chainAnimation(false)
                        .editMode(false)
                }
                Text("") {
                    ForEach(lineHeightArray, itemGeneratorFunc: {item: Int64, idx: Int64 =>
                        Span("${idx + 1}\n")
                            .fontColor(gutterTextColor)
                        ForEach(createArray(item-1), itemGeneratorFunc: {item1: Int64, idx1: Int64 =>
                            Span(" \n")
                        })
                    })
                }
                    .width(textCompWidth)
                    .height(textCompHeight)
                    .padding(top: 0.0, left: 0.0, right: 3.0, bottom: 0.0)
                    .fontSize(editorKitController.getFontSize().vp)
                    .textAlign(TextAlign.End)
                    .align(Alignment.Top)
                    .backgroundColor(gutterColor)
                    .onTouch( {event =>
                        editorKitController.setPopWindowHidden()
                    })
                Divider()
                    .height(textCompHeight)
                    .width(1.0)
                    .vertical(true)
                    .color(gutterDividerColor)
                    .onTouch({ event =>
                        editorKitController.setPopWindowHidden()
                    })
                RichEditor(controller)
                    .onTouch({ event =>
                        editorKitController.setPopWindowHidden()
                    })
                    .padding(top: 0.0, left: 3.0, right: 0.0, bottom: 0.0)
                    .width(subWidth - editorKitController.getCompWidth())
                    .layoutWeight(1)
                    .onReady({ =>
                        editorKitController.initRichEditor()
                    })
                    .onSelect({value: RichEditorSelection =>
                        editorKitController.setPopWindowHidden()
                        start = value.selection[0]
                        end = value.selection[1]
                    })
                    .aboutToIMEInput({value: RichEditorInsertValue =>
                        editorKitController.setPopWindowHidden()
                        insertValue = value.insertValue
                        insertOffset = value.insertOffset
                        return true
                    })
                    .onIMEInputComplete({ value: RichEditorTextSpanResult =>
                        inputComplete(value)
                    })
                    .aboutToDelete({ value: RichEditorDeleteValue =>
                        editorKitController.setPopWindowHidden()
                        deleteoffset = value.offset
                        deleteLength = value.length
                        return true
                    })
                    .onDeleteComplete({  =>
                        isDelete = true
                        if (let Some(curTimer) <- deleteTimer.value) {
                            curTimer.cancel()
                        }
                        deleteTimer.value = Timer.once(350 * Duration.millisecond) {
                            spawn(Main) {
                                deleteComplete()
                                deleteTimer.value = None
                            }
                        }
                    })
                    .onPaste({ event: PasteEvent =>
                        isPaste = true
                        if (let Some(myTimer) <- pasteTimer.value) {
                            myTimer.cancel()
                        }
                        pasteTimer.value = Timer.once(200 * Duration.millisecond) {
                            spawn(Main) {
                                paste()
                                isPaste = false
                                pasteTimer.value = None
                            }
                        }
                })
            }
            .backgroundColor(backgroundColor)
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.On)
        .height(subHeight)
        .width(subWidth)
        .onScroll({ offset =>
            editorKitController.setPopWindowHidden()
            scrollY = scroller.currentOffset().yOffset
            // Record the vertical slide offset in which the scroller slides, if offset.yOffset is greater than 0, it will slide down
            // otherwise, it will slide up.
            // If offset.yOffset is greater than or equal to 0, the color display area is [scrollY-this.height, scrollY+3*this.height] (<- 1, -> 3)
            // If offset.yOffset is less than 0, the color display area is [scrollY-2*this.height, scrollY+2*this.height] (<- 3, -> 1)
            // this.height is the screen height, scrollY is current screen top position
            if (offset.yOffset != 0.0) {
                this.scrollOffset = offset.yOffset
            }
            // Add stabilization to the scroller, swipe more than half of the current screen to trigger the updateEditorSpanStyle function
            if(let Some(curTimer) <- scrollTimer.value) {
                curTimer.cancel()
            }
            scrollTimer.value = Timer.once(50 * Duration.millisecond) {
                spawn(Main) {
                    if (math.abs(scrollY - editorKitController.tempScrollY) >= subHeight / 2.0 && !isDelete) {
                        editorKitController.isUpdate = true
                        editorKitController.updateEditorSpanStyle()
                        editorKitController.tempScrollY = scrollY
                        editorKitController.isUpdate = false
                    }
                    scrollTimer.value = None
                }
            }
        })
    }
    func setHeight(h: Float64) {
        subHeight = h
    }
    func setWidth(w: Float64) {
        subWidth = w
    }
    func setTextCompHeight(h: Float64) {
        textCompHeight = h
    }
    func setTextCompWidth(w: Float64) {
        textCompWidth = w + 3.0
    }
    func setAutoCompleteInfo(v: Bool, arr: ObservedArrayList<String>, pos!: (Float64, Float64) = (0.0, 0.0)) {
        valid = v
        suggestionList.clear()
        suggestionList = arr
        popX = pos[0]
        popY = pos[1]
    }
    func setlineHeightArray(arr: ObservedArrayList<Int64>) {
        lineHeightArray = arr
    }
    func setSuffix(str: String) {
        this.suffix = str
    }
    func setScrollTop() {
        this.scroller.scrollTo(xOffset: 0.px, yOffset: 0.px)
    }
    func flushScrollY() {
        scrollY = scroller.currentOffset().yOffset
    }
    func setEditorKitColor(backgroundColor: Color, gutterColor: Color, gutterTextColor: Color, gutterDividerColor: Color) {
        this.backgroundColor = backgroundColor
        this.gutterColor = gutterColor
        this.gutterTextColor = gutterTextColor
        this.gutterDividerColor = gutterDividerColor
    }
     private func paste() {
        editorKitController.getFullText()
        editorKitController.updateDisplay()
    }
    private func inputComplete(value: RichEditorTextSpanResult) {
        if (insertValue == "\n") {
            editorKitController.getEscapeText(Int64(insertOffset))
        } else {
            editorKitController.getFullText(spanResult: value)
        }
        editorKitController.getLines(idx: Int64(insertOffset))
        editorKitController.setPosition(insertOffset)
        editorKitController.setTempIndex(insertOffset)
        editorKitController.updateEditorSpanStyle(index: insertOffset)
        editorKitController.findSuffix()
        if (suffix != "" && !isPaste) {
            editorKitController.updateAutoComplete(popup: true, index: insertOffset, suffix: suffix, scrollY: scrollY)
        }
        if (isPaste) {
            editorKitController.updateAutoComplete()
        }
        var caretHeight: Float64
        var spanHeight: Float64
        (caretHeight, spanHeight) = editorKitController.getCaretHeight()
        if (caretHeight > subHeight + scrollY - spanHeight) {
            scroller.scrollTo(xOffset: 0.0, yOffset: caretHeight - subHeight + spanHeight)
        }
    }
    private func deleteComplete() {
        isDelete = false
        editorKitController.getFullText()
        editorKitController.getLines(idx: Int64(deleteoffset + 1 - deleteLength))
        editorKitController.updateEditorSpanStyle(index: deleteoffset)
        editorKitController.setPosition(deleteoffset - 1)
        editorKitController.setTempIndex(deleteoffset)
        editorKitController.findSuffix()
        if (suffix != "" && !isPaste) {
            editorKitController.updateAutoComplete(popup: true, index: deleteoffset, suffix: suffix, scrollY: scrollY)
        }
        if (isPaste) {
            editorKitController.updateAutoComplete()
        }
        var caretHeight: Float64
        var spanHeight: Float64
        (caretHeight, spanHeight) = editorKitController.getCaretHeight()
        if (caretHeight < scrollY + spanHeight) {
            scroller.scrollTo(xOffset: 0.0, yOffset: caretHeight - spanHeight)
        }
    }
}