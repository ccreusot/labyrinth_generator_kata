import Testing

@testable import labyrinth_generator_lib

@Test(
    "Any live cell with fewer than one live neighbours dies.",
    arguments: [
        (
            [
                [true, false, false],
                [false, false, false],
                [false, false, false],
            ],
            (x: 0, y: 0),
            false
        ),
        (
            [
                [false, false, false],
                [false, true, false],
                [false, false, false],
            ],
            (x: 1, y: 1),
            false
        ),
    ])
func underPopulationCase(board: [[Bool]], checkedPosition: (x: Int, y: Int), expectedState: Bool)
    async throws
{
    var b = board
    let res = tick(&b)

    #expect(res == true)
    #expect(b[checkedPosition.y][checkedPosition.x] == expectedState)
}

@Test(
    "Any live cell with more than four live neighbours dies.",
    arguments: [
        (
            // Input
            [
                [true, true, true],
                [true, true, true],
                [true, true, true],
            ],
            (x: 1, y: 1),
            false
        )
    ])
func overPopulationCase(board: [[Bool]], checkedPosition: (x: Int, y: Int), expectedState: Bool) {
    var b = board
    let res = tick(&b)

    #expect(res == true)
    #expect(b[checkedPosition.y][checkedPosition.x] == expectedState)
}

@Test(
    "Any dead cell without three living neighbours do not come to life.",
    arguments: [
        (
            // Input
            [
                [false, true, false],
                [true, false, true],
                [false, true, false],
            ],
            (x: 1, y: 1),
            false
        ),
        (
            // Input
            [
                [true, true, true],
                [true, false, true],
                [true, true, true],
            ],
            (x: 1, y: 1),
            false
        ),
        (
            // Input
            [
                [false, true, false],
                [true, false, false],
                [false, false, false],
            ],
            (x: 0, y: 0),
            false
        ),
    ])
func noZombieCell(board: [[Bool]], checkedPosition: (x: Int, y: Int), expectedState: Bool) {
    var b = board
    let res = tick(&b)

    #expect(res == true)
    #expect(b[checkedPosition.y][checkedPosition.x] == expectedState)
}

@Test(
    "Any dead cell with three living neighbours should come to life.",
    arguments: [
        (
            // Input
            [
                [false, true, false],
                [true, false, true],
                [false, false, false],
            ],
            (x: 1, y: 1),
            true
        ),
        (
            // Input
            [
                [true, true, true],
                [true, true, true],
                [true, true, false],
            ],
            (x: 2, y: 2),
            true
        ),
        (
            // Input
            [
                [true, true, false],
                [false, false, false],
                [false, true, false],
            ],
            (x: 0, y: 1),
            true
        ),
    ])
func cellBirth(board: [[Bool]], checkedPosition: (x: Int, y: Int), expectedState: Bool) {
    var b = board
    let res = tick(&b)

    #expect(res == true)
    #expect(b[checkedPosition.y][checkedPosition.x] == expectedState)
}

@Test(
    "When we send a the digger inside the labyrinth it try to follow the path",
    arguments: [
        (
            (x: 1, y: 1),
            // Input
            [
                [true, true, true, true, true],
                [false, false, false, false, true],
                [true, true, true, true, true],
            ],
            // Expect
            [
                [true, true, true, true, true],
                [false, false, false, false, false],
                [true, true, true, true, true],
            ]
        ),
        (
            (x: 1, y: 1),
            // Input
            [
                [true, true, true, true, true],
                [false, false, false, true, true],
                [true, true, false, false, true],
                [true, true, true, true, true],
            ],
            // Expect
            [
                [true, true, true, true, true],
                [false, false, false, true, true],
                [true, true, false, false, false],
                [true, true, true, true, true],
            ]
        ),
        (
            (x: 1, y: 2),
            // Input
            [
                [true, true, true, true, true],
                [true, true, false, false, true],
                [false, false, false, true, true],
                [true, true, true, true, true],
            ],
            // Expect
            [
                [true, true, true, true, true],
                [true, true, false, false, false],
                [false, false, false, true, true],
                [true, true, true, true, true],
            ]
        ),
        (
            (x: 1, y: 2),
            // Input
            [
                [true, true, true, true, true],
                [true, true, false, true, true],
                [false, false, false, true, true],
                [true, true, true, true, true],
            ],
            // Expect
            [
                [true, true, false, true, true],
                [true, true, false, true, true],
                [false, false, false, true, true],
                [true, true, true, true, true],
            ]
        ),
    ])
func digger(startPos: (x: Int, y: Int), board: Board, expect: Board) {
    #expect(diggerRun(board: board, x: startPos.x, y: startPos.y).0 == expect)
}
