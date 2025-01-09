# 在这个问题中，我们想要确定给定序列的所有可能的子序列。我们使用回溯法来解决这个问题。
# 时间复杂度：O(2^n)，其中 n 表示给定序列的长度。

从 __future__ 导入 annotations
从 typing 导入 Any

定义 generate_all_subsequences(sequence: list[Any]) -> 无:
    create_state_space_tree(sequence, [], 0)

定义 create_state_space_tree(sequence: list[Any], current_subsequence: list[Any], index: int) -> 无:
    """
    创建一个状态空间树，通过 DFS 遍历每个分支。
    我们知道每个状态恰好有两个子节点。
    当它到达给定序列的末尾时终止。

    :param sequence: 用于生成子序列的输入序列。
    :param current_subsequence: 当前正在构建的子序列。
    :param index: 序列中的当前索引。

    示例：
    >>> sequence = [3, 2, 1]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    [1]
    [2]
    [2, 1]
    [3]
    [3, 1]
    [3, 2]
    [3, 2, 1]

    >>> sequence = [" A", "B "]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    ['B']
    ['A']
    ['A', 'B']

    >>> sequence = []
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []

    >>> sequence = [1, 2, 3, 4]
    >>> current_subsequence = []
    >>> create_state_space_tree(sequence, current_subsequence, 0)
    []
    [4]
    [3]
    [3, 4]
    [2]
    [2, 4]
    [2, 3]
    [2, 3, 4]
    [1]
    [1, 4]
    [1, 3]
    [1, 3, 4]
    [1, 2]
    [1, 2, 4]
    [1, 2, 3]
    [1, 2, 3, 4]
    """
    如果 index == 长度(sequence):
        打印(current_subsequence)
        返回

    create_state_space_tree(sequence, current_subsequence, index + 1)
    current_subsequence.追加(sequence[index])
    create_state_space_tree(sequence, current_subsequence, index + 1)
    current_subsequence.弹出()

如果 __name__ == "__main__":
    seq: list[Any] = [1, 2, 3]
    generate_all_subsequences(seq)

    seq.清空()
    seq.扩展(["A", "B", "C"])