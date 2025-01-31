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
}

public enum Direction: Int {
    case right = 0
    case bottom = 1
    case left = 2
    case top = 3
}

public final class Dwarf {
    private let allDirections = [(dx: 1, dy: 0), (dx: 0, dy: 1), (dx: -1, dy: 0), (dx: 0, dy: -1)]

    private var directionIndex = 0

    public private(set) var position: Point
    public private(set) var visitedPositions: [Point: SquareHistory]

    public init(position: Point, direction: Direction = .right) {
        self.position = position
        self.visitedPositions = [:]  // put origin position in visited positions
        self.directionIndex = direction.rawValue
    }

    public func digOnce(board: Board) -> Board {
        guard !isOnEdge(board: board, point: position) else { return board }

        var newBoard = board
        let startDirection = directionIndex

        var canMove = false
        // Regarde devant
        // Si c'est pas visité et pas un mur avance
        // Sinon tourne de 90º
        // ...
        // Si revenu à la direction de départ
        // Avant tout droit en cassant le mur si besoin
        //
        // Si visité une fois, vas y
        // Si visité deux fois, tourne et casse un mur
        //
        // 1. Pas visité
        // 2. Visité 1 fois
        // 3. Un mur à casser
        // 4. Visité plus d'une fois
        repeat {
            let direction = allDirections[directionIndex]
            let lookupPosition = position.offset(direction)
            let history = visitedPositions[lookupPosition] ?? SquareHistory()

            guard !history.hasBeenVisited else {
                directionIndex = (directionIndex + 1) % allDirections.count
                continue
            }

            if !newBoard[lookupPosition.y][lookupPosition.x] {
                position = lookupPosition
                canMove = true
                break
            }
            directionIndex = (directionIndex + 1) % allDirections.count
        } while directionIndex != startDirection

        if !canMove {
            let direction = allDirections[directionIndex]
            let isBlockedByWall = newBoard[position.y + direction.dy][position.x + direction.dx]
            let lookupPosition = position.offset(direction)
            newBoard[lookupPosition.y][lookupPosition.x] = false
            position = lookupPosition
            visitedPositions[position] = SquareHistory(visitCount: 1, hasBeenDug: true)
        } else {
            let history = visitedPositions[position] ?? SquareHistory()
            visitedPositions[position] = history.visit()
        }

        return newBoard
    }

    public func dig(board: Board) -> Board {
        var newBoard = board

        while !isOnEdge(board: board, point: position) {  // TODO: check edges of ths newBoard
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

        //let dwarf = Dwarf(
        //    position: (x: size / 2, y: size / 2),
        //    direction: [.right, .top, .left, .bottom].randomElement() ?? .right
        //)
        //board = dwarf.dig(board: board)
        return board
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
