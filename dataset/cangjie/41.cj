// 测试 Windows API
// 仓颉语言团队 刘俊杰 2024.11.04

unsafe main() {
    let instance = GetModuleHandleA(EMPTY_STRING)
    // 注册窗口类
    let className = LibC.mallocCString('Cangjie Window')
    var windowClass = WNDCLASSEX(lpszClassName: className,
        hInstance: instance,
        lpfnWndProc: onMessage,
        hbrBackground: CreateSolidBrush(0x0095D6C0) // 中国传统色 欧碧
    )
    if (RegisterClassExA(inout windowClass) == 0) {
        println('RegisterClass Failed: ${GetLastError()}')
        return
    }
    // 创建窗口实例
    let windowName = LibC.mallocCString('Cangjie')
    let window = CreateWindowExA(
        0,                                   // 扩展样式
        className,                           // 窗口类名
        windowName,                          // 窗口标题
        WS_OVERLAPPEDWINDOW,                 // 窗口风格
        CW_USEDEFAULT, CW_USEDEFAULT,        // 窗口位置
        640, 480,                            // 窗口大小
        NULL,                                // 父窗口句柄
        NULL,                                // 菜单句柄
        instance,                            // 实例句柄
        NULL                                 // 附加参数
    )
    if (window.isNull()) {
        println('CreateWindow Failed: ${GetLastError()}')
        return
    }
    // 显示窗口
    ShowWindow(window, SW_SHOWNORMAL)
    UpdateWindow(window)
    // 启动消息循环
    var message = MSG()
    while (GetMessageA(inout message, NULL, 0, 0)) {
        TranslateMessage(inout message)
        DispatchMessageA(inout message)
    }
    // 退出消息循环
    println('Out of Message Loop')
    LibC.free(className)
    LibC.free(windowName)
}

@C
@CallingConv[STDCALL]
func onMessage(hWnd: Handle, msg: UInt32, wParam: UIntNative, lParam: UIntNative): Int64 {
    var result = 0
    const VK_ESCAPE: UInt16 = 0x1B
    if (msg == WM_KEYDOWN && wParam == UIntNative(VK_ESCAPE)) {
        unsafe { DestroyWindow(hWnd) }
    } else if (msg == WM_DESTROY) {
        unsafe { PostQuitMessage(0) }
    }
    result = unsafe { DefWindowProcA(hWnd, msg, wParam, lParam) }
    return result
}