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
public typealias Point = (x: Int, y: Int)
public typealias Direction = (dx: Int, dy: Int)

public func tick(_ board: inout Board) -> Bool {
    var newBoard = copy board
    for (y, row) in board.enumerated() {
        for (x, _) in row.enumerated() {
            newBoard[y][x] = tickCell(board, (x, y))
        }
    }
    board = newBoard
    return true
}

func tickCell(_ board: Board, _ position: (x: Int, y: Int)) -> Bool {
    let row = board.count
    let column = board[0].count
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

// 1. Try to move in your current direction
// 2. If you can't, turn to your right and back to (1)
// 3. If no direction other than the inverted previous direction allow you to move,  dig in  your start direction
func isOnEdge(board: Board, point: Point) -> Bool {
    return point.x == 0
        || point.y == 0
        || point.y == board.count - 1
        || point.x == board[point.y].count - 1
}

public func diggerRun(board: Board, x: Int, y: Int) -> (Board, [Point]) {
    let allDirections = [(dx: 1, dy: 0), (dx: 0, dy: 1), (dx: -1, dy: 0), (dx: 0, dy: -1)]
    var newBoard = board
    var dwarfPos = (x: x, y: y)
    var visitedPos: [Point] = []
    var directionIndex = 0

    while !isOnEdge(board: board, point: dwarfPos) {
        visitedPos.append(dwarfPos)
        let startDirection = directionIndex

        var canMove = false
        repeat {
            let direction = allDirections[directionIndex]

            guard
                dwarfPos.y + direction.dy < board.count
                    && dwarfPos.x + direction.dx < board[dwarfPos.y + direction.dy].count
            else {
                directionIndex = (directionIndex + 1) % allDirections.count
                continue
            }

            let hasBeenVisited = visitedPos.contains { pos in
                pos.x == dwarfPos.x + direction.dx && pos.y == dwarfPos.y + direction.dy
            }
            guard !hasBeenVisited else {
                directionIndex = (directionIndex + 1) % allDirections.count
                continue
            }

            if !newBoard[dwarfPos.y + direction.dy][dwarfPos.x + direction.dx] {
                dwarfPos.x += direction.dx
                dwarfPos.y += direction.dy
                canMove = true
                break
            }
            directionIndex = (directionIndex + 1) % allDirections.count
        } while directionIndex != startDirection

        if !canMove {
            let direction = allDirections[directionIndex]
            newBoard[dwarfPos.y + direction.dy][dwarfPos.x + direction.dx].toggle()
            dwarfPos.x += direction.dx
            dwarfPos.y += direction.dy
        }
    }

    return (newBoard, visitedPos)
}
