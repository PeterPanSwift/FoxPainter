import SwiftUI

/// A resolution-independent drawing. All artwork uses a 1,000 × 1,000 design space.
/// The original reference is not embedded; the silhouette, fur and props are paths.
struct FoxIllustration: View {
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 1_000
            context.translateBy(x: (size.width - 1_000 * scale) / 2,
                                y: (size.height - 1_000 * scale) / 2)
            context.scaleBy(x: scale, y: scale)
            FoxPainter(context: context).draw()
        }
        .accessibilityLabel("白色小狐狸，藍色大眼睛，穿著 Swift 上衣，左手托著筆電，右手拿著紅色桌球拍。")
    }
}

private struct FoxPainter {
    var context: GraphicsContext
    private let outline = Color(red: 0.46, green: 0.40, blue: 0.39)
    private let cream = Color(red: 1, green: 0.97, blue: 0.93)
    private let shade = Color(red: 0.72, green: 0.68, blue: 0.70)
    private let warmWhite = Color(red: 0.95, green: 0.90, blue: 0.87)

    func draw() {
        var shadow = context
        shadow.addFilter(.blur(radius: 15))
        shadow.fill(Path(ellipseIn: CGRect(x: 295, y: 912, width: 535, height: 35)),
                    with: .color(outline.opacity(0.13)))
        tail()
        legs()
        ears()
        shirt()
        head()
        laptop()
        paddle()
        rightPaw()
    }

    // MARK: - Drawing primitives

    private func path(_ build: (inout Path) -> Void) -> Path {
        var result = Path()
        build(&result)
        return result
    }

    private func paint(_ shape: Path, _ colors: [Color], from: CGPoint = CGPoint(x: 350, y: 150),
                       to: CGPoint = CGPoint(x: 650, y: 850), line: Double = 2.2) {
        context.fill(shape, with: .linearGradient(Gradient(colors: colors), startPoint: from, endPoint: to))
        if line > 0 {
            context.stroke(shape, with: .color(outline.opacity(0.72)),
                           style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
        }
    }

    private func stroke(_ shape: Path, _ color: Color, _ width: Double = 2) {
        context.stroke(shape, with: .color(color),
                       style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    private func ellipse(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ colors: [Color], line: Double = 0) {
        paint(Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)), colors,
              from: CGPoint(x: x, y: y), to: CGPoint(x: x + w * 0.5, y: y + h), line: line)
    }

    /// Stable, curved hair strokes clipped to each body part; no random state during rendering.
    private func fur(in shape: Path, bounds: CGRect, count: Int, direction: Double, seed: Int) {
        var clipped = context
        clipped.clip(to: shape)
        for index in 0..<count {
            let a = noise(index * 7 + seed)
            let b = noise(index * 7 + seed + 1)
            let x = bounds.minX + a * bounds.width
            let y = bounds.minY + b * bounds.height
            let length = 5 + noise(index * 7 + seed + 2) * 16
            let angle = direction + (a - 0.5) * 1.2
            let dx = cos(angle) * length
            let dy = sin(angle) * length
            let hair = path { p in
                p.m(x, y)
                p.q(x + dx, y + dy, x + dx * 0.2 - 2, y + dy * 0.7)
            }
            let color = index.isMultiple(of: 3) ? Color.white.opacity(0.30) : outline.opacity(0.06)
            clipped.stroke(hair, with: .color(color), style: StrokeStyle(lineWidth: 0.75, lineCap: .round))
        }
    }

    private func noise(_ n: Int) -> Double {
        let value = sin(Double(n) * 78.233 + 0.123) * 43_758.5453
        return value - floor(value)
    }

    // MARK: - Tail and paws

    private func tail() {
        let shape = path { p in
            p.m(552, 681)
            p.c(632, 752, 662, 687, 705, 668)
            p.c(750, 647, 789, 659, 814, 686)
            p.l(801, 667)
            p.c(870, 709, 886, 816, 849, 875)
            p.l(854, 849)
            p.c(831, 902, 797, 928, 751, 927)
            p.l(766, 918)
            p.c(717, 933, 684, 913, 666, 889)
            p.c(718, 890, 682, 858, 661, 854)
            p.c(584, 837, 548, 788, 552, 681)
            p.closeSubpath()
        }
        paint(shape, [shade, warmWhite, cream, warmWhite, shade],
              from: CGPoint(x: 569, y: 789), to: CGPoint(x: 865, y: 747))
        let highlight = path { p in
            p.m(616, 750)
            p.c(704, 750, 720, 646, 794, 701)
            p.c(843, 742, 836, 839, 791, 879)
            p.c(754, 910, 716, 905, 687, 895)
            p.c(755, 882, 688, 834, 672, 819)
            p.c(643, 800, 625, 781, 616, 750)
            p.closeSubpath()
        }
        var softHighlight = context
        softHighlight.clip(to: shape)
        softHighlight.addFilter(.blur(radius: 10))
        softHighlight.fill(highlight, with: .linearGradient(
            Gradient(colors: [cream.opacity(0.1), cream, Color.white.opacity(0.6)]),
            startPoint: CGPoint(x: 616, y: 750), endPoint: CGPoint(x: 820, y: 880)))
        fur(in: shape, bounds: CGRect(x: 560, y: 660, width: 315, height: 270), count: 900, direction: 1.0, seed: 60)
        for offset in [0.0, 12, 25] {
            stroke(path { p in
                p.m(711 + offset, 677 + offset * 0.12)
                p.c(779 + offset, 649 + offset, 851 + offset * 0.3, 735 + offset, 843 - offset * 0.2, 812 + offset)
            }, Color.white.opacity(0.45), 2)
        }
    }

    private func legs() {
        let left = path { p in
            p.m(322, 664)
            p.c(300, 715, 323, 783, 343, 845)
            p.c(350, 869, 318, 868, 322, 895)
            p.c(321, 919, 359, 922, 393, 908)
            p.c(432, 896, 424, 849, 442, 789)
            p.c(460, 760, 458, 702, 449, 683)
            p.closeSubpath()
        }
        let right = path { p in
            p.m(436, 693)
            p.c(424, 734, 448, 777, 458, 815)
            p.c(464, 844, 473, 868, 459, 885)
            p.c(436, 905, 445, 931, 475, 934)
            p.c(510, 944, 552, 927, 556, 901)
            p.c(563, 860, 563, 822, 574, 769)
            p.c(585, 719, 574, 688, 555, 672)
            p.closeSubpath()
        }
        paint(left, [shade, warmWhite, cream, shade], from: CGPoint(x: 302, y: 694), to: CGPoint(x: 458, y: 849))
        paint(right, [shade, warmWhite, cream, warmWhite], from: CGPoint(x: 442, y: 704), to: CGPoint(x: 549, y: 885))
        fur(in: left, bounds: CGRect(x: 307, y: 676, width: 142, height: 242), count: 410, direction: 1.3, seed: 201)
        fur(in: right, bounds: CGRect(x: 436, y: 688, width: 140, height: 248), count: 420, direction: 1.6, seed: 908)
        for x in [341.0, 363, 466, 489, 514] {
            let y = x < 400 ? 910.0 : 930.0
            stroke(path { p in p.m(x, y); p.q(x - 5, y - 25, x - 15, y - 13) }, outline.opacity(0.36), 1.8)
        }
    }

    // MARK: - Ears and face

    private func ears() {
        let left = path { p in
            p.m(310, 247)
            p.c(278, 222, 280, 102, 315, 38)
            p.c(325, 9, 367, 44, 400, 70)
            p.c(426, 91, 442, 122, 452, 166)
            p.l(438, 239)
            p.closeSubpath()
        }
        paint(left, [cream, warmWhite, shade], from: CGPoint(x: 338, y: 65), to: CGPoint(x: 380, y: 250))
        let innerLeft = path { p in
            p.m(316, 209)
            p.c(298, 170, 312, 78, 330, 60)
            p.c(351, 65, 392, 134, 405, 179)
            p.l(354, 238)
            p.closeSubpath()
        }
        paint(innerLeft, [Color(red: 0.48, green: 0.42, blue: 0.46), Color(red: 0.76, green: 0.64, blue: 0.64), warmWhite],
              from: CGPoint(x: 330, y: 104), to: CGPoint(x: 393, y: 218), line: 1)
        let right = path { p in
            p.m(534, 151)
            p.c(572, 104, 640, 60, 675, 55)
            p.c(707, 42, 708, 147, 695, 198)
            p.c(688, 231, 679, 260, 649, 272)
            p.l(589, 234)
            p.closeSubpath()
        }
        paint(right, [cream, warmWhite, shade], from: CGPoint(x: 643, y: 82), to: CGPoint(x: 682, y: 255))
        let innerRight = path { p in
            p.m(577, 165)
            p.c(611, 119, 649, 92, 670, 85)
            p.c(689, 120, 674, 206, 650, 231)
            p.closeSubpath()
        }
        paint(innerRight, [Color(red: 0.43, green: 0.38, blue: 0.43), Color(red: 0.72, green: 0.60, blue: 0.61)],
              from: CGPoint(x: 638, y: 120), to: CGPoint(x: 651, y: 232))
        let tufts = path { p in
            p.m(309, 178); p.l(330, 193); p.l(321, 158); p.l(349, 176)
            p.l(334, 127); p.q(380, 172, 379, 137); p.l(405, 213); p.l(329, 240)
            p.closeSubpath()
            p.m(582, 188); p.l(643, 135); p.l(627, 158); p.l(654, 151)
            p.l(633, 181); p.l(653, 178); p.q(624, 203, 643, 205)
            p.l(646, 214); p.l(619, 243); p.closeSubpath()
        }
        paint(tufts, [cream, warmWhite, shade], line: 1)
        fur(in: left, bounds: CGRect(x: 290, y: 33, width: 150, height: 218), count: 310, direction: -1.4, seed: 3)
        fur(in: right, bounds: CGRect(x: 536, y: 58, width: 171, height: 209), count: 320, direction: -1.0, seed: 77)
    }

    private func head() {
        let face = path { p in
            p.m(312, 212)
            p.q(373, 146, 326, 166)
            p.q(433, 121, 405, 142)
            p.l(426, 104); p.l(443, 124); p.l(470, 93); p.l(461, 117)
            p.l(507, 85); p.l(490, 115); p.l(531, 103); p.l(514, 122)
            p.c(582, 111, 628, 165, 649, 213)
            p.q(671, 235, 656, 234); p.l(653, 245); p.l(680, 271); p.l(661, 269)
            p.q(679, 298, 671, 292); p.l(657, 296); p.l(682, 318); p.l(663, 317)
            p.q(684, 343, 674, 339); p.q(654, 346, 669, 346); p.l(668, 361)
            p.l(650, 361); p.c(626, 408, 564, 426, 505, 429)
            p.c(428, 435, 352, 416, 314, 389)
            p.l(325, 389); p.q(282, 361, 296, 381); p.l(300, 362)
            p.q(270, 336, 280, 352); p.l(288, 337)
            p.q(263, 316, 271, 331); p.q(287, 322, 275, 324)
            p.l(263, 303); p.q(289, 306, 280, 307)
            p.l(265, 288); p.q(292, 286, 280, 294)
            p.l(277, 273); p.q(299, 256, 292, 270)
            p.l(283, 247); p.q(312, 212, 305, 246)
            p.closeSubpath()
        }
        paint(face, [cream, Color(red: 1, green: 0.975, blue: 0.952), warmWhite, shade],
              from: CGPoint(x: 462, y: 184), to: CGPoint(x: 509, y: 480), line: 2.6)
        fur(in: face, bounds: CGRect(x: 267, y: 98, width: 420, height: 335), count: 1800, direction: 1.2, seed: 125)
        // Soft cheeks and muzzle sit underneath the glossy eyes.
        var blush = context
        blush.addFilter(.blur(radius: 9))
        blush.fill(Path(ellipseIn: CGRect(x: 299, y: 321, width: 82, height: 23)),
                   with: .color(Color(red: 1, green: 0.66, blue: 0.59).opacity(0.27)))
        blush.fill(Path(ellipseIn: CGRect(x: 552, y: 346, width: 82, height: 23)),
                   with: .color(Color(red: 1, green: 0.66, blue: 0.59).opacity(0.29)))
        ellipse(365, 340, 141, 70, [cream, cream.opacity(0.1)])
        ellipse(433, 350, 112, 65, [cream, cream.opacity(0.1)])
        eye(x: 344, y: 254, width: 65, height: 80, tilt: -0.13)
        eye(x: 493, y: 279, width: 70, height: 75, tilt: 0.14)
        stroke(path { p in p.m(380, 213); p.q(406, 211, 394, 196) }, Color(red: 0.62, green: 0.48, blue: 0.39), 4)
        stroke(path { p in p.m(520, 234); p.q(548, 237, 531, 217) }, Color(red: 0.62, green: 0.48, blue: 0.39), 4)
        let mouth = path { p in
            p.m(400, 363)
            p.q(473, 370, 431, 379)
            p.c(464, 395, 454, 410, 440, 410)
            p.c(421, 410, 412, 394, 400, 363)
            p.closeSubpath()
        }
        paint(mouth, [Color(red: 0.16, green: 0.055, blue: 0.04), Color(red: 0.56, green: 0.13, blue: 0.10)],
              from: CGPoint(x: 435, y: 364), to: CGPoint(x: 440, y: 409), line: 2.5)
        let tongue = path { p in
            p.m(418, 395); p.c(426, 374, 448, 378, 460, 391)
            p.q(440, 408, 452, 408); p.q(418, 395, 426, 410); p.closeSubpath()
        }
        paint(tongue, [Color(red: 0.92, green: 0.35, blue: 0.30), Color(red: 1, green: 0.59, blue: 0.49)], line: 1)
        stroke(path { p in p.m(440, 394); p.l(437, 402) }, Color(red: 0.73, green: 0.25, blue: 0.21).opacity(0.5), 1)
        let nose = path { p in
            p.m(413, 334); p.c(415, 324, 443, 325, 448, 334)
            p.c(451, 341, 438, 350, 431, 352)
            p.c(425, 351, 411, 342, 413, 334); p.closeSubpath()
        }
        paint(nose, [Color(red: 0.27, green: 0.21, blue: 0.19), .black],
              from: CGPoint(x: 430, y: 328), to: CGPoint(x: 435, y: 350), line: 1.6)
        stroke(path { p in p.m(418, 333); p.q(438, 332, 427, 328) }, cream.opacity(0.7), 2.3)
        stroke(path { p in p.m(431, 351); p.l(430, 360)
            p.c(416, 373, 398, 370, 393, 354)
            p.m(430, 360); p.c(444, 378, 468, 380, 477, 368)
        }, Color(red: 0.24, green: 0.16, blue: 0.13), 2.6)
        ellipse(390, 351, 4, 6, [outline])
        ellipse(474, 365, 5, 6, [outline])
    }

    private func eye(x: Double, y: Double, width: Double, height: Double, tilt: Double) {
        var local = context
        local.translateBy(x: x + width / 2, y: y + height / 2)
        local.rotate(by: .radians(tilt))
        local.translateBy(x: -width / 2, y: -height / 2)
        let painter = FoxPainter(context: local)
        let socket = painter.path { p in
            p.m(-6, height * 0.48)
            p.c(1, -14, width * 0.92, -13, width + 2, height * 0.51)
            p.q(width + 8, height * 0.66, width + 4, height * 0.64)
            p.l(width - 1, height * 0.68)
            p.c(width - 2, height * 1.06, 6, height * 1.11, 0, height * 0.70)
            p.closeSubpath()
        }
        painter.paint(socket, [.black, Color(red: 0.16, green: 0.10, blue: 0.09)],
                      from: .zero, to: CGPoint(x: width, y: height), line: 2)
        painter.ellipse(4, 10, width - 8, height - 9, [Color(red: 0.90, green: 0.83, blue: 0.82), .white], line: 0.8)
        painter.ellipse(15, 11, width - 21, height - 10,
                        [Color(red: 0.02, green: 0.05, blue: 0.07), Color(red: 0.04, green: 0.17, blue: 0.23), Color(red: 0.31, green: 0.67, blue: 0.79)], line: 1)
        painter.ellipse(20, 20, width - 30, height - 32, [.black, Color(red: 0.015, green: 0.055, blue: 0.075)])
        painter.ellipse(24, 17, 14, 16, [.white, Color.white.opacity(0.95)])
        painter.ellipse(width - 19, height - 18, 6, 7, [.white])
        painter.ellipse(25, height - 14, 8, 5, [Color.cyan.opacity(0.25)])
        painter.stroke(painter.path { p in p.m(-3, 24); p.c(7, -7, width - 7, -8, width + 2, 28) }, cream, 3)
    }

    // MARK: - Clothing and accessories

    private func shirt() {
        let shape = path { p in
            p.m(381, 424)
            p.c(339, 433, 325, 448, 306, 482)
            p.l(297, 549); p.l(326, 573)
            p.c(326, 611, 311, 640, 305, 672)
            p.c(358, 718, 517, 727, 582, 675)
            p.l(567, 608); p.l(598, 581)
            p.c(616, 537, 597, 472, 560, 448)
            p.l(516, 423); p.closeSubpath()
        }
        paint(shape, [shade, cream, Color(red: 1, green: 0.975, blue: 0.95), warmWhite, shade],
              from: CGPoint(x: 299, y: 545), to: CGPoint(x: 613, y: 604), line: 2.4)
        let collar = path { p in
            p.m(379, 425); p.c(373, 471, 464, 487, 522, 429)
            p.l(507, 418); p.c(475, 454, 406, 451, 391, 422); p.closeSubpath()
        }
        paint(collar, [shade, cream, warmWhite], from: CGPoint(x: 415, y: 423), to: CGPoint(x: 441, y: 470), line: 1.5)
        stroke(path { p in p.m(315, 665); p.c(389, 703, 506, 707, 571, 672) }, outline.opacity(0.18), 2)
        for x in [333.0, 548, 560] {
            stroke(path { p in p.m(x, 489); p.q(x - 5, 551, x - 17, 526) }, outline.opacity(0.17), 3)
        }
        stroke(path { p in p.m(330, 637); p.q(367, 671, 341, 659)
            p.m(540, 649); p.q(522, 678, 538, 667)
        }, outline.opacity(0.16), 2)
        // Swift is an SF Symbol, drawn as a vector just like the rest of the illustration.
        var symbol = context.resolve(Image(systemName: "swift"))
        symbol.shading = .linearGradient(Gradient(colors: [Color(red: 1, green: 0.40, blue: 0.13), Color(red: 0.98, green: 0.19, blue: 0.06)]),
                                         startPoint: CGPoint(x: 364, y: 503), endPoint: CGPoint(x: 449, y: 587))
        context.draw(symbol, in: CGRect(x: 364, y: 503, width: 85, height: 84))
        context.draw(Text(verbatim: "Swift").font(.system(size: 47, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.14)), at: CGPoint(x: 410, y: 628))
    }

    private func laptop() {
        let paw = path { p in
            p.m(186, 575); p.c(177, 562, 168, 592, 187, 608)
            p.c(218, 636, 284, 622, 316, 604)
            p.l(325, 574); p.l(224, 572); p.closeSubpath()
        }
        paint(paw, [cream, warmWhite, shade], from: CGPoint(x: 226, y: 567), to: CGPoint(x: 243, y: 625))
        fur(in: paw, bounds: CGRect(x: 176, y: 568, width: 147, height: 60), count: 180, direction: 0.4, seed: 578)
        let base = path { p in
            p.m(182, 551); p.l(320, 546); p.l(432, 568); p.l(436, 579)
            p.l(330, 602); p.l(177, 574); p.closeSubpath()
        }
        paint(base, [Color(red: 0.77, green: 0.78, blue: 0.77), Color(red: 0.38, green: 0.41, blue: 0.42)],
              from: CGPoint(x: 320, y: 549), to: CGPoint(x: 326, y: 602), line: 2)
        let keyboard = path { p in
            p.m(285, 553); p.l(327, 552); p.l(414, 568); p.l(353, 580); p.closeSubpath()
        }
        paint(keyboard, [Color(red: 0.12, green: 0.17, blue: 0.18)], line: 1)
        for y in [558.0, 564, 570] {
            stroke(path { p in p.m(307, y); p.l(383, y + 11) }, Color.white.opacity(0.22), 1)
        }
        stroke(path { p in p.m(330, 590); p.l(427, 573) }, cream.opacity(0.7), 2)
        for x in [340.0, 351, 362] {
            stroke(path { p in p.m(x, 594 - (x - 340) * 0.2); p.l(x + 5, 593 - (x - 340) * 0.2) }, .black.opacity(0.7), 3)
        }
        let lid = path { p in
            p.m( 100, 410); p.q( 90, 424, 85, 410)
            p.l(137, 567); p.q(151, 576, 139, 574)
            p.l(320, 598); p.q(333, 588, 335, 601)
            p.l(295, 433); p.q(282, 421, 293, 421)
            p.closeSubpath()
        }
        paint(lid, [Color(red: 0.80, green: 0.77, blue: 0.76), Color(red: 0.58, green: 0.60, blue: 0.63), Color(red: 0.44, green: 0.48, blue: 0.51)],
              from: CGPoint(x: 239, y: 416), to: CGPoint(x: 142, y: 588), line: 2.5)
        stroke(path { p in p.m( 100, 415); p.l(281, 426); p.q(291, 435, 289, 426); p.l(328, 586)
            p.q(321, 594, 332, 597)
        }, Color.white.opacity(0.85), 2)
        var apple = context.resolve(Image(systemName: "apple.logo"))
        apple.shading = .color(Color(red: 0.23, green: 0.28, blue: 0.30))
        context.draw(apple, in: CGRect(x: 184, y: 478, width: 35, height: 43))
        let fingers = path { p in
            p.m(188, 602)
            p.c(171, 585, 173, 572, 181, 570)
            p.q(195, 590, 192, 565)
            p.c(185, 562, 204, 561, 210, 578)
            p.c(211, 567, 222, 573, 228, 590)
            p.c(231, 579, 241, 590, 242, 602)
            p.c(232, 620, 203, 612, 188, 602); p.closeSubpath()
        }
        paint(fingers, [cream, warmWhite, shade], from: CGPoint(x: 205, y: 575), to: CGPoint(x: 219, y: 624), line: 1.5)
        stroke(path { p in p.m(196, 576); p.q(202, 599, 192, 592)
            p.m(211, 581); p.q(218, 603, 208, 597)
        }, outline.opacity(0.25), 1.5)
    }

    private func paddle() {
        let handle = path { p in
            p.m(550, 479); p.l(581, 491); p.l(519, 638)
            p.q(495, 625, 507, 643); p.closeSubpath()
        }
        paint(handle, [Color(red: 0.15, green: 0.20, blue: 0.19), Color(red: 0.31, green: 0.32, blue: 0.25), Color(red: 0.07, green: 0.11, blue: 0.10)],
              from: CGPoint(x: 520, y: 562), to: CGPoint(x: 548, y: 573))
        stroke(path { p in p.m(502, 615); p.l(522, 624) }, Color(red: 0.86, green: 0.24, blue: 0.09), 7)
        stroke(path { p in p.m(498, 623); p.l(519, 632) }, Color(red: 0.78, green: 0.50, blue: 0.24), 3)
        let wood = path { p in
            p.m(520, 481); p.l(538, 522); p.l(568, 535); p.l(613, 511); p.closeSubpath()
        }
        paint(wood, [Color(red: 1, green: 0.75, blue: 0.43), Color(red: 0.70, green: 0.45, blue: 0.25)], line: 2)
        let blade = path { p in
            p.m(520, 482)
            p.c(502, 450, 529, 383, 574, 367)
            p.c(619, 348, 658, 377, 666, 415)
            p.c(675, 457, 641, 521, 605, 524)
            p.c(578, 516, 544, 501, 520, 482); p.closeSubpath()
        }
        paint(blade, [Color(red: 0.96, green: 0.23, blue: 0.14), Color(red: 0.85, green: 0.10, blue: 0.06), Color(red: 0.70, green: 0.08, blue: 0.04)],
              from: CGPoint(x: 557, y: 380), to: CGPoint(x: 650, y: 520), line: 3)
        stroke(path { p in p.m(582, 365); p.c(683, 346, 691, 469, 611, 521) }, Color(red: 1, green: 0.75, blue: 0.45), 3)
        var rubber = context
        rubber.clip(to: blade)
        for row in 0..<40 {
            for column in 0..<32 {
                let x = 510 + Double(column) * 5 + Double(row % 2) * 2.5
                let y = 359 + Double(row) * 4.5
                rubber.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.1, height: 1.1)), with: .color(Color.white.opacity(0.10)))
            }
        }
    }

    private func rightPaw() {
        let arm = path { p in
            p.m(598, 523)
            p.c(629, 528, 647, 586, 626, 612)
            p.c(603, 650, 564, 632, 547, 606)
            p.l(551, 549); p.closeSubpath()
        }
        paint(arm, [shade, warmWhite, cream, shade], from: CGPoint(x: 625, y: 551), to: CGPoint(x: 553, y: 626))
        fur(in: arm, bounds: CGRect(x: 543, y: 521, width: 98, height: 114), count: 280, direction: 1.5, seed: 131)
        let paw = path { p in
            p.m(565, 530)
            p.c(545, 514, 516, 520, 515, 537)
            p.q(538, 550, 514, 545)
            p.c(511, 537, 502, 554, 509, 566)
            p.q(532, 577, 518, 571)
            p.c(500, 563, 501, 585, 514, 592)
            p.c(532, 603, 552, 619, 575, 609)
            p.c(599, 595, 592, 552, 565, 530); p.closeSubpath()
        }
        paint(paw, [cream, warmWhite, shade], from: CGPoint(x: 530, y: 533), to: CGPoint(x: 583, y: 617), line: 2)
        stroke(path { p in p.m(516, 544); p.q(543, 554, 532, 542)
            p.m(511, 566); p.q(537, 575, 527, 565)
        }, outline.opacity(0.30), 2)
        fur(in: paw, bounds: CGRect(x: 505, y: 523, width: 86, height: 94), count: 170, direction: 0.5, seed: 721)
    }
}

/// Compact Bézier helpers keep control points beside the corresponding silhouette.
private extension Path {
    mutating func m(_ x: Double, _ y: Double) { move(to: CGPoint(x: x, y: y)) }
    mutating func l(_ x: Double, _ y: Double) { addLine(to: CGPoint(x: x, y: y)) }
    mutating func q(_ x: Double, _ y: Double, _ cx: Double, _ cy: Double) {
        addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cx, y: cy))
    }
    mutating func c(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) {
        addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x1, y: y1), control2: CGPoint(x: x2, y: y2))
    }
}

#Preview("White fox") {
    FoxIllustration()
        .frame(width: 390, height: 390)
        .background(Color(red: 0.97, green: 0.965, blue: 0.955))
}
