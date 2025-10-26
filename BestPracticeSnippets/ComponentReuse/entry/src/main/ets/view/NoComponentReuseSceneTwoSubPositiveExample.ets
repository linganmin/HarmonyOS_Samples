import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';

@Entry
@Component
struct NoComponentReuseSceneTwoSubPositiveExample {
  private dataSource: ItemDataSource = new ItemDataSource();

  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: ItemData) => {
          ListItem() {
            if (item.type === 0) {
              SingleImageNewsContent({ item: item })
            } else if (item.type === 1) {
              ThreeImageNewsContent({ item: item })
            } else {
              VideoNewsContent({ item: item })
            }
          }
        }, (item: ItemData) => item.id.toString())
      }
    }
  }
}

// [Start NoComponentReuseSceneTwoSubPositiveExample]
@Reusable
@Component
struct SingleImageNewsContent {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  @Builder
  myBuilder(item: ItemData) {
    TopView({ item: item })
    MiddleSingleImageView({ item: item })
    BottomView({ item: item })
  }

  build() {
    Column() {
      this.myBuilder(this.item)
    }

    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct ThreeImageNewsContent {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  @Builder
  myBuilder(item: ItemData) {
    TopView({ item: item })
    MiddleThreeImageView({ item: item })
    BottomView({ item: item })
  }

  build() {
    Column() {
      this.myBuilder(this.item)
    }

    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct VideoNewsContent {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  @Builder
  myBuilder(item: ItemData) {
    TopView({ item: item })
    MiddleVideoView({ item: item })
    BottomView({ item: item })
  }

  build() {
    Column() {
      this.myBuilder(this.item)
    }

    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

// [End NoComponentReuseSceneTwoSubPositiveExample]

@Component
struct TopView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}

@Component
struct BottomView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}

@Component
struct MiddleSingleImageView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}

@Component
struct MiddleThreeImageView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}

@Component
struct MiddleVideoView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}