// [Start segment6]
@Entry
@Component
struct ReuseType5 {
  build() {
    Column() {
      List({ space: 30 }) {
        LazyForEach(this.momentDataSource, (item: FriendMoment, index: number) => {
          ListItem() {
            Column() {
              if (item.type === 1) {
                CardItem({ item: item })
                  .reuseId('ItemMiddle1')
              } else if (item.type === 2) {
                CardItem({ item: item })
                  .reuseId('ItemMiddle2')
              } else if (item.type === 3) {
                CardItem({ item: item })
                  .reuseId('ItemMiddle3')
              } else {
              }
            }
          }
        }, (item: FriendMoment) => JSON.stringify(item))
      }
    }
  }
}


@Reusable
@Component
struct CardItem {
  build() {
    Column() {
      ItemTop({ item: this.item })
      if (this.item.type === 1) { // 模拟条件1
        ItemMiddle1({ item: this.item })
      } else if (this.item.type === 2) { // 模拟条件2
        ItemMiddle2({ item: this.item })
      } else if (this.item.type === 3) {
        ItemMiddle3({ item: this.item }) // // 模拟条件3
      } else {
      }
      ItemBottom({ item: this.item })
    }
  }
}


@Component
struct ItemTop {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}


@Component
struct ItemBottom {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}


@Component
struct ItemMiddle1 {
  build() {
    Column() {
      CommentText()
      MiddleSingleImage({ item: this.item })
    }
  }
}


@Component
struct ItemMiddle2 {
  build() {
    Column() {
      CommentText()
      MiddleGrid({ item: this.item })
    }
  }
}


@Component
struct ItemMiddle3 {
  build() {
    Column() {
      CommentText()
      MiddleVideo({ item: this.item })
    }
  }
}


@Component
struct MiddleSingleImage {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}


@Component
struct MiddleGrid {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}


@Component
struct MiddleVideo {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}


@Component
struct CommentText {
  // [StartExclude segment6]
  build() {
    Column() {
    }
  }
  // [EndExclude segment6]
}
// [Start segment6]