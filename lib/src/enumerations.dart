enum TileType {
  /// A normal tile.
  ///
  /// This is the default tile.
  normal,

  /// A ghost tile.
  ///
  /// This is used to show the orignal size and position of a tile while it is being modified.
  ghost,

  /// A selected tile.
  ///
  /// This is used to show the size and position of a tile that is being modified.
  selected,
}

enum CreateEventTrigger {
  /// Creates event on tap gesture (drag in this option is Desktop only).
  tapAndDrag,

  /// Creates event on tap hold gesture (drag in this option is Desktop only).
  longPressAndDrag,

  /// Creates event on tap hold gesture after finishing Dragging (works on mobile).
  longPressDrag,
}

