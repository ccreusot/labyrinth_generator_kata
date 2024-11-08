import Foundation
import labyrinth_generator_lib

var board: [[Bool]] = []
let boardSide = 50
let sarterSide = 3

let sarter = (boardSide - sarterSide) / 2

for y in 0..<boardSide {
    board.append([])
    for x in 0..<boardSide {
        if x >= sarter && x < sarter + sarterSide && y >= sarter && y < sarter + sarterSide {
            board[y].append(Bool.random())
        } else {
            board[y].append(false)
        }
    }
}

func printBoard(_ board: [[Bool]]) {
    for y in 0..<board.count {
        for x in 0..<board[y].count {
            print(board[y][x] ? "X" : " ", terminator: "")
        }
        print()
    }
}

print("Initial board")
printBoard(board)
for _ in 0..<50 {
    print("\u{001B}[2J")
    _ = tick(&board)
    printBoard(board)
    Thread.sleep(forTimeInterval: 0.5)
}
