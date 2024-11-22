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

func diggerRun(board: Board, x: Int, y: Int) -> Board {
    var newBoard = board
    var dwarfPos = (x: x, y: y)
    var dwarfVec = (dx: 0, dy: 0)

    while dwarfPos.x + 1 < board[dwarfPos.y].count {
        // dwarfVec.dx = 1

        if newBoard[dwarfPos.y][dwarfPos.x + 1] {

            if !newBoard[dwarfPos.y + 1][dwarfPos.x] {
                // dwarfVec.dy = 1
                dwarfPos.y += 1
                continue
            }

            if !newBoard[dwarfPos.y][dwarfPos.x - 1] {
                // dwarfVec.dx = -1
                dwarfPos.x -= 1
                continue
            }

            if !newBoard[dwarfPos.y - 1][dwarfPos.x] {
                // dwarfVec.dy = -1
                dwarfPos.y -= 1
                continue
            }

            newBoard[dwarfPos.y][dwarfPos.x + 1].toggle()
        }

        dwarfPos.x += 1
    }

    return newBoard
}
