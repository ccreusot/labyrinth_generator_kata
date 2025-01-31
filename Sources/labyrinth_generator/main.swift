import Foundation
import labyrinth_generator_lib
import raylib

let boardSide = 100
let generator = LabyrinthGenerator()
var board: [[Bool]] = generator.generateLabyrinth(size: boardSide)

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

let cellSize: Int32 = 8
var runLife = false
var runDwarf = false
let windowWidth = Int32(boardSide) * cellSize + cellSize * 2
let windowHeight = Int32(boardSide) * cellSize + cellSize * 2

let generationFPS = 30
let dwarfFPS = 15
var currentFrame = 0

InitWindow(
    windowWidth, windowHeight,
    "hello from swift")
SetTargetFPS(Int32(generationFPS))
//HideCursor()

func isInBound(position: Point) -> Bool {
    return position.x >= 0 && position.x < boardSide && position.y >= 0 && position.y < boardSide
}

let boarder = Rectangle(x: 0.0, y: 0.0, width: Float(windowWidth), height: Float(windowHeight))
var dwarfs: [Dwarf] = []

while !WindowShouldClose() {
    if IsKeyReleased(Int32(raylib.KEY_SPACE.rawValue)) {
        runLife = !runLife
    }

    if IsKeyReleased(Int32(raylib.KEY_D.rawValue)) {
        runDwarf = !runDwarf
    }

    if IsKeyReleased(Int32(raylib.KEY_R.rawValue)) {
        board = generator.generateLabyrinth(size: boardSide)
        dwarfs = []
        runDwarf = false
        runLife = false
    }

    if IsMouseButtonPressed(
        Int32(raylib.MOUSE_BUTTON_MIDDLE.rawValue)) || IsKeyReleased(Int32(raylib.KEY_X.rawValue))
    {
        dwarfs.append(
            Dwarf(
                position: Point(
                    x: Int(GetMouseX() / cellSize) - 1,
                    y: Int(GetMouseY() / cellSize) - 1
                ),
                direction: [.right, .top, .left, .bottom].randomElement() ?? .right
            )
        )
    }

    //if IsMouseButtonDown(Int32(raylib.MOUSE_BUTTON_LEFT.rawValue)) {
    //    let x = Int(GetMouseX() / cellSize) - 1
    //    let y = Int(GetMouseY() / cellSize) - 1

    //    if isInBound(position: (x: x, y: y)) {
    //        print("click here (x: \(x), y: \(y))")
    //        board[y][x] = true
    //    }
    //}

    //if IsMouseButtonDown(Int32(raylib.MOUSE_BUTTON_RIGHT.rawValue)) {
    //    let x = Int(GetMouseX() / cellSize) - 1
    //    let y = Int(GetMouseY() / cellSize) - 1

    //    if isInBound(position: (x: x, y: y)) {
    //        print("click here (x: \(x), y: \(y))")
    //        board[y][x] = false
    //    }
    //}

    currentFrame = (currentFrame + 1) % generationFPS
    //if runLife {
    //    _ = tick(&board)
    //}

    if !dwarfs.isEmpty && runDwarf && (currentFrame % (generationFPS / dwarfFPS)) == 0 {
        for i in 0..<dwarfs.count {
            board = dwarfs[i].digOnce(board: board)
        }
        //runDwarf = false
    }

    BeginDrawing()
    _ = {
        ClearBackground(white)
        DrawRectangleLinesEx(boarder, Float(cellSize), blue)
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                if board[y][x] {
                    DrawRectangle(
                        Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize,
                        cellSize,
                        cellSize, black)
                }
                //DrawRectangle(int posX, int posY, int width, int height, Color color);
                for dwarf in dwarfs {
                    if dwarf.position.y == y && dwarf.position.x == x {
                        DrawRectangle(
                            Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize,
                            cellSize,
                            cellSize, green)
                    }
                }

            }
        }

        for (dwarfIndex, dwarf) in dwarfs.enumerated() {
            let path = dwarf.visitedPositions
            for (position, history) in path {
                var fadedRed = red
                var fadedYellow = yellow

                //let alpha = UInt8(200.0 * (Double(index) / Double(path.count)) + 55)
                //fadedRed.a = alpha
                //fadedYellow.a = alpha
                //DrawRectangle(
                //    Int32(x) * cellSize + cellSize, Int32(y) * cellSize + cellSize, cellSize,
                //    cellSize, white)
                DrawRectangle(
                    Int32(position.x) * cellSize + cellSize, Int32(position.y) * cellSize + cellSize, cellSize,
                    cellSize, history.hasBeenDug ? fadedRed : fadedYellow)
            }
            DrawRectangle(
                Int32(dwarf.position.x) * cellSize + cellSize,
                Int32(dwarf.position.y) * cellSize + cellSize, cellSize,
                cellSize, green)
        }

        DrawText("Ticking: \(runLife)", 20, 20, 24, green)
        DrawText("Digging: \(runDwarf)", 20, 52, 24, green)
    }()
    EndDrawing()
}

CloseWindow()
