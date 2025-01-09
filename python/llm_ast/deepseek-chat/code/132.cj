函 數 計 算 一 的 數 量 (數 字: 整 數) -> 整 數:
    """
    計 算 32 位 整 數 中 設 置 位 的 數 量，使 用 Brian Kernighan 的 方 法。
    參 考 - https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetKernighan
    >>> 計 算 一 的 數 量(25)
    3
    >>> 計 算 一 的 數 量(37)
    3
    >>> 計 算 一 的 數 量(21)
    3
    >>> 計 算 一 的 數 量(58)
    4
    >>> 計 算 一 的 數 量(0)
    0
    >>> 計 算 一 的 數 量(256)
    1
    >>> 計 算 一 的 數 量(-1)
    Traceback (most recent call last):
        ...
    ValueError: 輸 入 必 須 是 非 負 整 數
    >>> 計 算 一 的 數 量(0.8)
    Traceback (most recent call last):
        ...
    ValueError: 輸 入 必 須 是 非 負 整 數
    >>> 計 算 一 的 數 量("25")
    Traceback (most recent call last):
        ...
    ValueError: 輸 入 必 須 是 非 負 整 數
    """
    如 果 不 是 實 例(數 字, 整 數) 或 數 字 < 0:
        拋 出 錯 誤(ValueError("輸 入 必 須 是 非 負 整 數"))

    計 數 = 0
    當 數 字:
        # 這 樣 我 們 可 以 直 接 到 達 下 一 個 設 置 位 (下 一 個 1)，而 不 是 循 環
        # 通 過 每 個 位 並 檢 查 是 否 為 1，因 此
        # 循 環 不 會 運 行 32 次，它 只 會 運 行 設 置 位 的 數 量 次
        數 字 &= 數 字 - 1
        計 數 += 1
    返 回 計 數