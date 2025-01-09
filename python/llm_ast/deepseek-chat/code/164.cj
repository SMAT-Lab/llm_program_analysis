函 取最高置位位置(數: 整) -> 整:
    """
    返回一個數的最高置位的位置。
    參考 - https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogObvious
    >>> 取最高置位位置(25)
    5
    >>> 取最高置位位置(37)
    6
    >>> 取最高置位位置(1)
    1
    >>> 取最高置位位置(4)
    3
    >>> 取最高置位位置(0)
    0
    >>> 取最高置位位置(0.8)
    Traceback (most recent call last):
        ...
    類型錯誤: 輸入值必須是 '整' 類型
    """
    若 非 是實例(數, 整):
        拋 類型錯誤("輸入值必須是 '整' 類型")
    
    位置 = 0
    當 數:
        位置 += 1
        數 >>= 1
    
    返 位置


若 __name__ == "__main__":
    引入 doctest
    doctest.測試模塊()