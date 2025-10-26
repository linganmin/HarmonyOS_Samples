interface FriendMoment {
  id: string;
  type: number;
  content: string;
  images?: string[];
  videoUrl?: string;
}

// [Start Case4]
@Entry
@Component
struct ReuseType3 {
  // [StartExclude Case4]
  private momentDataSource: IDataSource = {
    totalCount: () => 0,
    getData: (index: number) => ({
      id: index.toString(),
      type: 1,
      content: "",
      images: []
    }),
    registerDataChangeListener: () => {
    },
    unregisterDataChangeListener: () => {
    }
  }

  // [EndExclude Case4]
  @Builder
  itemBuilderSingleImage(item: FriendMoment) { // Single big picture list item
    // ...
  }

  @Builder
  itemBuilderGrid(item: FriendMoment) { // list item in nine square brackets
    // ...
  }

  @Builder
  itemBuilderVideo(item: FriendMoment) { // Video list item
    // ...
  }

  build() {
    Column() {
      List() {
        LazyForEach(this.momentDataSource, (item: FriendMoment) => {
          ListItem() {
            if (item.type === 1) { // Use different combinations depending on the type
              this.itemBuilderSingleImage(item);
            } else if (item.type === 2) {
              this.itemBuilderGrid(item);
            } else if (item.type === 3) {
              this.itemBuilderVideo(item);
            } else {
              // ...
            }
          }
        }, (moment: FriendMoment) => JSON.stringify(moment))
      }
    }
  }
}


@Reusable
@Component
struct ItemTop {
  // [StartExclude Case4]
  build() {
    Column() {
    }
  }

  // [EndExclude Case4]
}


@Reusable
@Component
struct ItemBottom {
  // [StartExclude Case4]
  build() {
    Column() {
    }
  }

  // [EndExclude Case4]
}


@Reusable
@Component
struct MiddleSingleImage {
  // [StartExclude Case4]
  build() {
    Column() {
    }
  }

  // [EndExclude Case4]
}


@Reusable
@Component
struct MiddleGrid {
  // [StartExclude Case4]
  build() {
    Column() {
    }
  }

  // [EndExclude Case4]
}


@Reusable
@Component
struct MiddleVideo {
  // [StartExclude Case4]
  build() {
    Column() {
    }
  }

  // [EndExclude Case4]
}

// [End Case4]