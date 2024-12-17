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
let red = Color(r: 255, g: 0, b: 0, a: 255)
let yellow = Color(r: 255, g: 255, b: 0, a: 255)
let green = Color(r: 50, g: 200, b: 128, a: 255)

let cellSize: Int32 = 16
var runLife = false
var runDwarf = false
var dwarfX: Int? = nil
var dwarfY: Int? = nil
let windowWidth = Int32(boardSide) * cellSize + cellSize * 2
let windowHeight = Int32(boardSide) * cellSize + cellSize * 2
InitWindow(
    windowWidth, windowHeight,
    "hello from swift")
SetTargetFPS(30)
//HideCursor()

func isInBound(position: Point) -> Bool {
    return position.x >= 0 && position.x < boardSide && position.y >= 0 && position.y < boardSide
}

let boarder = Rectangle(x: 0.0, y: 0.0, width: Float(windowWidth), height: Float(windowHeight))
var path: [(pos: Point, hasDug: Bool)] = []

while !WindowShouldClose() {
    if runLife {
        _ = tick(&board)
    }

    if runDwarf, let dwarfX, let dwarfY {
        let (newBoard, newPath) = diggerRun(board: board, x: dwarfX, y: dwarfY)
        board = newBoard
        path = newPath
        runDwarf = false
    }

    if IsKeyReleased(Int32(raylib.KEY_SPACE.rawValue)) {
        runLife = !runLife
    }

    if IsKeyReleased(Int32(raylib.KEY_D.rawValue)) {
        runDwarf = !runDwarf
    }

    if IsMouseButtonPressed(
        Int32(raylib.MOUSE_BUTTON_MIDDLE.rawValue)) || IsKeyReleased(Int32(raylib.KEY_X.rawValue))
    {
        dwarfX = Int(GetMouseX() / cellSize) - 1
        dwarfY = Int(GetMouseY() / cellSize) - 1
    }

    if IsMouseButtonDown(Int32(raylib.MOUSE_BUTTON_LEFT.rawValue)) {
        let x = Int(GetMouseX() / cellSize) - 1
        let y = Int(GetMouseY() / cellSize) - 1

        if isInBound(position: (x: x, y: y)) {
            print("click here (x: \(x), y: \(y))")
            board[y][x] = true
        }
    }

    if IsMouseButtonDown(Int32(raylib.MOUSE_BUTTON_RIGHT.rawValue)) {
        let x = Int(GetMouseX() / cellSize) - 1
        let y = Int(GetMouseY() / cellSize) - 1

        if isInBound(position: (x: x, y: y)) {
            print("click here (x: \(x), y: \(y))")
            board[y][x] = false
        }
    }

    BeginDrawing()
    _ = {
        ClearBackground(white)
        DrawRectangleLinesEx(boarder, Float(cellSize), blue)
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                //DrawRectangle(int posX, int posY, int width, int height, Color color);
                if dwarfY == y && dwarfX == x {
                    DrawRectangle(
                        Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                        cellSize, yellow)
                } else if board[y][x] {
                    DrawRectangle(
                        Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                        cellSize, black)
                }
            }
        }

        for (index, ((x, y), hasDug)) in path.enumerated() {
            var fadedRed = red
            var fadedYellow = yellow

            let alpha = UInt8(200.0 * (Double(index) / Double(path.count)) + 55)
            fadedRed.a = alpha
            fadedYellow.a = alpha
            DrawRectangle(
                Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                cellSize, white)
            DrawRectangle(
                Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                cellSize, hasDug ? fadedRed : fadedYellow)
        }

        DrawText("Ticking: \(runLife)", 20, 20, 24, green)
        DrawText("Digging: \(runDwarf)", 20, 52, 24, green)
    }()
    EndDrawing()
}

CloseWindow()
