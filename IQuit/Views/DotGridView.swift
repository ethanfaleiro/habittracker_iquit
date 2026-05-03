import SwiftUI

// 365 dots, 25 columns × 14 rows = 350 dots + last row of 15
// We use 25 cols: 365 = 25×14 + 15, so row 15 has 15 dots (more than half full, looks fine)
// Actually let's do it smarter: render all 365, let last row be partial but left-aligned

struct DotGridView: View {
    let dots: [DotDay]        // exactly 365 items
    let theme: ThemeColors
    let availableHeight: CGFloat

    private let cols = 25
    private let hPad: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let totalW  = geo.size.width - hPad * 2
            let rows    = 15  // 25×14 = 350 + 15 leftover = 365 total, fits in 15 rows
            let cellW   = totalW / CGFloat(cols)
            let cellH   = availableHeight / CGFloat(rows)
            let dotSize = min(cellW, cellH) * 0.62

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: cols),
                spacing: 0
            ) {
                ForEach(dots) { dot in
                    Circle()
                        .fill(dot.state == .clean ? theme.dotClean : theme.dotFuture)
                        .frame(width: dotSize, height: dotSize)
                        .frame(width: cellW, height: cellH)
                }
            }
            .padding(.horizontal, hPad)
        }
    }
}
