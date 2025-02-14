// The Swift Programming Language
// https://docs.swift.org/swift-book

// Automate Cellulaire, qui génère des labyrinthes.
// Reprend les règles du jeu de la vie de Conway
// avec twist une cellule survie avec 1 ou 5 voisins.
// Rules:
// Any live cell with fewer than one live neighbours dies (referred to as underpopulation).
// Any live cell with more than five live neighbours dies (referred to as overpopulation).
// Any live cell with one to five live neighbours lives, unchanged, to the next generation.
// Any dead cell with exactly three live neighbours comes to life.
import Foundation

public typealias Board = [[Bool]]
public typealias Vector = (dx: Int, dy: Int)

public struct Point: Equatable, Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func offset(_ offset: Vector) -> Point {
        return Point(
            x: x + offset.dx,
            y: y + offset.dy
        )
    }
}

public struct SquareHistory {
    public let visitCount: Int
    public let hasBeenDug: Bool

    init(visitCount: Int = 0, hasBeenDug: Bool = false) {
        self.visitCount = visitCount
        self.hasBeenDug = hasBeenDug
    }

    public var hasBeenVisited: Bool { visitCount > 0 }

    func visit() -> SquareHistory {
        return SquareHistory(visitCount: visitCount + 1, hasBeenDug: hasBeenDug)
    }

    func interestLevel(
        isWall: Bool, position: Point, offset: Vector, visitedPos: [Point: SquareHistory]
    )
        -> Int
    {
        if isWall {
            let behindWallPos =
                position
                .offset(offset)
                .offset(offset)
            return visitedPos[behindWallPos] != nil ? Int.max : 1
        }
        return visitCount
    }
}

public enum Direction: Int {
    case right = 0
    case bottom = 1
    case left = 2
    case top = 3
}

public final class Dwarf {
    private let allDirections: [Vector]

    private var lastPosition: Point?

    private var diggingStrike: Int = 0

    private let maxLastDigAction: Int = 2
    private var lastDigAction: Int

    public private(set) var position: Point
    public private(set) var visitedPositions: [Point: SquareHistory]

    public init(position: Point) {
        self.position = position
        self.visitedPositions = [:]  // put origin position in visited positions
        self.lastDigAction = maxLastDigAction
        self.allDirections = [
            (dx: 1, dy: 0),
            (dx: 0, dy: 1),
            (dx: -1, dy: 0),
            (dx: 0, dy: -1),
        ].shuffled()
    }

    public func digOnce(board: Board) -> Board {
        guard !isOnEdge(board: board, point: position) else { return board }

        var newBoard = board

        // Regarde devant
        // Si c'est pas visité et pas un mur avance
        // Sinon tourne de 90º
        // ...
        // Si revenu à la direction de départ
        // Avance tout droit en cassant le mur si besoin
        //
        // Si visité une fois, vas y
        // Si visité deux fois, tourne et casse un mur
        //
        // 1. Pas visité
        // 2. Visité 1 fois
        // 3. Un mur à casser
        // 4. Visité plus d'une fois
        //
        // sort:
        // a < b -> a
        // a > b -> b
        // a == b && a == last -> b
        // -> a

        // 1. Select destination
        var historyTuple = allDirections.map { direction in
            let lookupPosition = position.offset(direction)
            return (
                position: lookupPosition,
                offset: direction,
                history: visitedPositions[lookupPosition] ?? SquareHistory()
            )
        }
        historyTuple.sort { tupleA, tupleB in
            let isAWall = board[tupleA.position.y][tupleA.position.x]
            let isBWall = board[tupleB.position.y][tupleB.position.x]
            let interestLevelA = tupleA.history.interestLevel(
                isWall: isAWall, position: position, offset: tupleA.offset,
                visitedPos: visitedPositions)
            let interestLevelB = tupleB.history.interestLevel(
                isWall: isBWall, position: position, offset: tupleB.offset,
                visitedPos: visitedPositions)
            // Already
            if interestLevelA < interestLevelB {
                return true
            } else if interestLevelA > interestLevelB {
                return false
            } else {
                return lastPosition == nil || tupleA.position != lastPosition!
            }
        }
        let selectedTuple = historyTuple[0]
        let destination = selectedTuple.position
        let isBlockedByWall = newBoard[destination.y][destination.x]

        // 2. Move
        lastPosition = position
        position = destination

        // 3. Break wall if needed then update visited position
        if isBlockedByWall {
            newBoard[destination.y][destination.x] = false
            visitedPositions[position] = SquareHistory(visitCount: 1, hasBeenDug: true)
            diggingStrike += 1
            lastDigAction = 0
        } else {
            visitedPositions[position] = selectedTuple.history.visit()
            diggingStrike = 0
            lastDigAction = min(maxLastDigAction, lastDigAction + 1)
        }

        return newBoard
    }

    public func dig(board: Board) -> Board {
        var newBoard = board

        while !isOnEdge(board: board, point: position) {
            newBoard = digOnce(board: newBoard)
        }

        return newBoard
    }
}

public final class LabyrinthGenerator {
    public init() {
    }

    private func newBoard(_ size: Int) -> [[Bool]] {
        var board: [[Bool]] = []
        for y in 0..<size {
            board.append([])
            for _ in 0..<size {
                board[y].append(false)
            }
        }
        return board
    }

    private func tick(_ board: inout Board) -> Bool {
        var newBoard = copy board
        var hasChanged = false
        for (y, row) in board.enumerated() {
            for (x, _) in row.enumerated() {
                newBoard[y][x] = tickCell(board, (x, y))
                hasChanged = hasChanged || board[y][x] != newBoard[y][x]
            }
        }
        board = newBoard
        return hasChanged
    }

    private func tickCell(_ board: Board, _ position: (x: Int, y: Int)) -> Bool {
        let row = board.count
        let column = board[0].count

        //guard
        //    position.x != 0 && position.x != column - 1
        //        && position.y != 0 && position.y != row - 1
        //else { return true }

        var countNeighboor = 0

        for y in (position.y - 1)...(position.y + 1) {
            guard y >= 0 && y < row else { continue }

            for x in (position.x - 1)...(position.x + 1) {
                guard x >= 0 && x < column && (y != position.y || x != position.x) else {
                    continue
                }

                if board[y][x] {
                    countNeighboor += 1
                }
            }
        }

        if countNeighboor == 3 && !board[position.y][position.x] {
            return true  // Raise the dead
        }

        return board[position.y][position.x] && countNeighboor >= 1 && countNeighboor <= 5
    }

    private func generateDwarfs(boardSize: Int) -> [Dwarf] {
        var dwarfs: [Dwarf] = []
        let factor = 8
        for y in 1..<factor {
            let positionY = y * (boardSize / factor)
            for x in 1..<factor {
                let positionX = x * (boardSize / factor)
                dwarfs.append(Dwarf(position: Point(x: positionX, y: positionY)))

            }
        }
        return dwarfs
    }

    private func distance(from point1: Point, to point2: Point) -> Double {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return Double(dx * dx + dy * dy).squareRoot()
    }

    public func generateLabyrinth(size: Int = 50) -> Board {
        var board = newBoard(size)

        for _ in 0...(size * size / 4) {
            let x = Int.random(in: 0..<size)
            let y = Int.random(in: 0..<size)

            board[y][x] = true
        }

        var historicBoard: [Board] = []
        historic: while tick(&board) {
            if !historicBoard.isEmpty {
                for i in 1..<historicBoard.count {
                    if historicBoard[historicBoard.count - i] == board {
                        break historic
                    }
                }
            }
            historicBoard.append(board)
        }

        for y in 0..<size {
            board[y][0] = true
            board[y][size - 1] = true
        }

        for x in 1..<(size - 1) {
            board[0][x] = true
            board[size - 1][x] = true
        }

        let dwarfs = generateDwarfs(boardSize: size)
        var allDwarfsOnEdge = true
        repeat {
            allDwarfsOnEdge = true
            for dwarf in dwarfs {
                allDwarfsOnEdge = allDwarfsOnEdge && isOnEdge(board: board, point: dwarf.position)
                if !isOnEdge(board: board, point: dwarf.position) {
                    board = dwarf.digOnce(board: board)
                }
            }
        } while !allDwarfsOnEdge

        var exits: [Point] = []
        // Top
        for y in 0..<1 {
            for x in 0..<size {
                if !board[y][x] {
                    exits.append(Point(x: x, y: y))
                }

                board[y][x] = true
            }
        }

        // Bottom
        for y in size - 1..<size {
            for x in 0..<size {
                if !board[y][x] {
                    exits.append(Point(x: x, y: y))
                }

                board[y][x] = true
            }
        }

        // left
        for x in 0..<1 {
            for y in 0..<size {
                if !board[y][x] {
                    exits.append(Point(x: x, y: y))
                }

                board[y][x] = true
            }
        }

        // right
        for x in size - 1..<size {
            for y in 0..<size {
                if !board[y][x] {
                    exits.append(Point(x: x, y: y))
                }

                board[y][x] = true
            }
        }

        let first = exits.first!
        var maxDist = 0.0
        var farthestPoint = first
        for point in exits {
            let curDist = distance(from: first, to: point)
            if curDist > maxDist {
                maxDist = curDist
                farthestPoint = point
            }
        }

        board[first.y][first.x] = false
        board[farthestPoint.y][farthestPoint.x] = false

        return board
    }
}

public func saveBoard(board: [[Bool]], in fileName: String) {
    let fileManager = FileManager.default
    if let currentDir = fileManager.currentDirectoryPath as String? {
        let data = board.map { row in
            row.map { val in
                val ? "x" : " "
            }.joined()
        }.joined(separator: "\n")

        let filePath = (currentDir as NSString).appendingPathComponent(fileName)

        do {
            try data.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Unable to write on the file")
        }
    }

}

// 1. Try to move in your current direction
// 2. If you can't, turn to your right and back to (1)
// 3. If no direction other than the inverted previous direction allow you to move,  dig in  your start direction
func isOnEdge(board: Board, point: Point) -> Bool {
    return point.x == 0
        || point.y == 0
        || point.y == board.count - 1
        || point.x == board[point.y].count - 1
}
