import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';

@Entry
@Component
struct NoComponentReuseSceneTwoPositiveExample {
  private dataSource: ItemDataSource = new ItemDataSource();

  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: ItemData) => {
          ListItem() {
            NewsContent({ item: item }).reuseId(`${item.type}`)
          }
        }, (item: ItemData) => item.id.toString())
      }
    }
  }
}

@Reusable
@Component
struct NewsContent {
  @ObjectLink item: ItemData;

  @Builder
  myBuilder(item: ItemData) {
    TopView({ item: item })
    if (item.type === 0) {
      MiddleTextView({ item: item })
    } else if (item.type === 1) {
      MiddleTextNoTitleView({ item: item })
    } else if (item.type === 2) {
      MiddleSingleImageView({ item: item })
    } else if (item.type === 3) {
      MiddleThreeImageView({ item: item })
    } else if (item.type === 4) {
      MiddleVideoView({ item: item })
    } else if (item.type === 5) {
      // ...
    } else {
      // ...
    }
    BottomView({ item: item })
  }

  build() {
    Column() {
      this.myBuilder(this.item)
    }

    // ...
  }
}

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

// [Start ReuseIdClassificationIsTooDetailedScenePositiveExample]
@Component
struct MiddleTextView {
  @ObjectLink item: ItemData;

  build() {
    Column() {
      Text('title')
        .visibility(this.item.isShowTitle) // Switch effects through the visibility property.
      Text()
    }

    // ...
  }
}

// [Start ReuseIdClassificationIsTooDetailedScenePositiveExample]

@Component
struct MiddleTextNoTitleView {
  @ObjectLink item: ItemData;

  build() {
    // ...
  }
}