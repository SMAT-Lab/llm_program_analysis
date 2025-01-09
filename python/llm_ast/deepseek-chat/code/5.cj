「
  The sum-of-subsetsproblem states that a set of non-negative integers, and a 
  value M, determine all possible subsets of the given set whose summation sum 
  equal to given M. 
  
  Summation of the chosen numbers must be equal to given number M and one number 
  can be used only once. 
」

從 __future__ 引入 annotations

定義 generate_sum_of_subsets_soln(nums: 列表[整數], max_sum: 整數) -> 列表[列表[整數]]:
    result: 列表[列表[整數]] = []
    path: 列表[整數] = []
    num_index = 0
    remaining_nums_sum = 總和(nums)
    建立狀態空間樹(nums, max_sum, num_index, path, result, remaining_nums_sum)
    返回 result

定義 建立狀態空間樹(
    nums: 列表[整數],
    max_sum: 整數,
    num_index: 整數,
    path: 列表[整數],
    result: 列表[列表[整數]],
    remaining_nums_sum: 整數,
) -> 無:
    「
        建立一個狀態空間樹，使用深度優先搜索遍歷每個分支。
        當滿足以下任一條件時，終止節點的分支。
        此算法遵循深度優先搜索，並在節點不可分支時回溯。
    」
    如果 總和(path) > max_sum 或 (remaining_nums_sum + 總和(path)) < max_sum:
        返回
    如果 總和(path) == max_sum:
        result.添加(path)
        返回
    對於 index 在 範圍(num_index, 長度(nums)):
        建立狀態空間樹(
            nums,
            max_sum,
            index + 1,
            [*path, nums[index]],
            result,
            remaining_nums_sum - nums[index],
        )

「
 移除註釋以從用戶獲取輸入
  
 打印(" 輸入元素")
」