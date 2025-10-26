import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';

@Entry
@Component
struct NoComponentReuseSceneTwoPositiveExample {
  private dataSource: ItemDataSource = new ItemDataSource();

  build() {
    Column() {
      // [Start NoComponentReuseSceneTwoPositiveExample01]
      List() {
        LazyForEach(this.dataSource, (item: ItemData) => {
          ListItem() {
            NewsContent({ item: item }).reuseId(`${item.type}`)
          }
        }, (item: ItemData) => item.id.toString())
      }

      // [Start NoComponentReuseSceneTwoPositiveExample01]
    }
  }
}

// [Start NoComponentReuseSceneTwoPositiveExample02]
@Reusable
@Component
struct NewsContent {
  // [StartExclude NoComponentReuseSceneTwoPositiveExample02]
  @ObjectLink item: ItemData;

  @Builder
  myBuilder(item: ItemData) {
    TopView({ item: item })
    if (item.type === 0) {
      MiddleSingleImageView({ item: item })
    } else if (item.type === 1) {
      MiddleThreeImageView({ item: item })
    } else {
      MiddleVideoView({ item: item })
    }
    BottomView({ item: item })
  }

  build() {
    Column() {
      this.myBuilder(this.item)
    }

    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoPositiveExample02]
}

// [End NoComponentReuseSceneTwoPositiveExample02]

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