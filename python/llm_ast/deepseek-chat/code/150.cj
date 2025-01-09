// 定义深度优先搜索函数
function depth_first_search(possible_board, diagonal_right_collisions, diagonal_left_collisions, boards, n) {
    // 获取当前棋盘的行数
    let row = possible_board.length;

    // 如果行数等于棋盘大小，说明每一行都有一个皇后
    if (row == n) {
        // 将棋盘转换为字符串形式并添加到结果中
        let board = [];
        for (let i = 0; i < n; i++) {
            let line = "";
            for (let j = 0; j < n; j++) {
                if (j == possible_board[i]) {
                    line += "Q ";
                } else {
                    line += ". ";
                }
            }
            board.push(line);
        }
        boards.push(board);
        return;
    }

    // 遍历每一列，寻找可能的解
    for (let col = 0; col < n; col++) {
        // 检查是否有冲突
        if (possible_board.includes(col) || diagonal_right_collisions.includes(row - col) || diagonal_left_collisions.includes(row + col)) {
            continue;
        }

        // 如果没有冲突，继续递归搜索
        depth_first_search(
            [...possible_board, col],
            [...diagonal_right_collisions, row - col],
            [...diagonal_left_collisions, row + col],
            boards,
            n
        );
    }
}

// 定义N皇后问题求解函数
function n_queens_solution(n) {
    let boards = [];
    depth_first_search([], [], [], boards, n);

    // 打印所有解
    for (let board of boards) {
        for (let line of board) {
            print(line);
        }
        print("");
    }

    print(boards.length, "solutions were found.");
}

// 如果作为主程序运行，执行测试
if (__name__ == "__main__") {
    n_queens_solution(4);
}