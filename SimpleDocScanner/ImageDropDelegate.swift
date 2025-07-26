import SwiftUI

struct ImageDropDelegate: DropDelegate {
    let item: UIImage
    @Binding var images: [UIImage]
    @Binding var draggedImage: UIImage?

    func performDrop(info: DropInfo) -> Bool {
        draggedImage = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedImage = draggedImage,
              draggedImage != item,
              let fromIndex = images.firstIndex(of: draggedImage),
              let toIndex = images.firstIndex(of: item)
        else {
            return
        }

        withAnimation {
            images.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
}
