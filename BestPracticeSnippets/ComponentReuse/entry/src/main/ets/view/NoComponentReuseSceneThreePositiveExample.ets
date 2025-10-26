import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';

@Entry
@Component
struct NoComponentReuseSceneThreePositiveExample {
  private dataSource: ItemDataSource = new ItemDataSource();

  @Builder
  itemBuilderSingleImage(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleSingleImageView({ item: item })
      BottomView({ item: item })
    }
  }

  @Builder
  itemBuilderThreeImage(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleSingleImageView({ item: item })
      BottomView({ item: item })
    }
  }

  @Builder
  itemBuilderVideo(item: ItemData) {
    Column() {
      TopView({ item: item })
      MiddleSingleImageView({ item: item })
      BottomView({ item: item })
    }
  }

  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: ItemData) => {
          ListItem() {
            if (item.type === 0) {
              this.itemBuilderSingleImage(item)
            } else if (item.type === 1) {
              this.itemBuilderThreeImage(item)
            } else {
              this.itemBuilderVideo(item)
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
struct TopView {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct BottomView {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct MiddleSingleImageView {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct MiddleThreeImageView {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

@Reusable
@Component
struct MiddleVideoView {
  // [StartExclude NoComponentReuseSceneTwoSubPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude NoComponentReuseSceneTwoSubPositiveExample]
}

// [End NoComponentReuseSceneTwoSubPositiveExample]