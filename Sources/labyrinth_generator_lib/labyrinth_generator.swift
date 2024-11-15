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

// Next time: Cell doesn't survive if she have 5 cells

public func tick(_ board: inout [[Bool]]) -> Bool {
    var newBoard = copy board
    for (y, row) in board.enumerated() {
        for (x, _) in row.enumerated() {
            newBoard[y][x] = tickCell(board, (x, y))
        }
    }
    board = newBoard
    return true
}

func tickCell(_ board: [[Bool]], _ position: (x: Int, y: Int)) -> Bool {
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

// Little dwarf to complete the labyrinth
// Small png that will dig the rest of the paths of the labyrinth
