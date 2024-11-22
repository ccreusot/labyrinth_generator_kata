import Foundation
import labyrinth_generator_lib
import raylib

var board: [[Bool]] = []
let boardSide = 50
let sarterSide = 4

let sarter = (boardSide - sarterSide) / 2

for y in 0..<boardSide {
    board.append([])
    for _ in 0..<boardSide {
        board[y].append(false)
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

let white = Color(r: 255, g: 255, b: 255, a: 255)
let black = Color(r: 0, g: 0, b: 0, a: 255)
let blue = Color(r: 0, g: 0, b: 255, a: 255)

let cellSize: Int32 = 16
var runLife = false
let windowWidth = Int32(boardSide) * cellSize + cellSize * 2
let windowHeight = Int32(boardSide) * cellSize + cellSize * 2
InitWindow(
    windowWidth, windowHeight,
    "hello from swift")
SetTargetFPS(8)
//HideCursor()

let boarder = Rectangle(x: 0.0, y: 0.0, width: Float(windowWidth), height: Float(windowHeight))

while !WindowShouldClose() {
    if runLife {
        _ = tick(&board)
    }

    if IsKeyPressed(Int32(raylib.KEY_SPACE.rawValue)) {
        runLife = !runLife
    }

    if IsMouseButtonDown(Int32(raylib.MOUSE_BUTTON_LEFT.rawValue)) {
        let x = Int(GetMouseX() / cellSize) - 1
        let y = Int(GetMouseY() / cellSize) - 1

        if y != -1 && x != -1 {
            print("click here (x: \(x), y: \(y))")
            board[y][x] = !board[y][x]
        }
    }

    BeginDrawing()
    _ = {
        ClearBackground(white)
        DrawRectangleLinesEx(boarder, Float(cellSize), blue)
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                //DrawRectangle(int posX, int posY, int width, int height, Color color);
                if board[y][x] {
                    DrawRectangle(
                        Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                        cellSize, black)
                }
            }
        }
    }()
    EndDrawing()
}

CloseWindow()
