import { ItemDataSource } from '../model/ItemDataSource';
import { ItemData } from '../model/ItemData';

@Entry
@Component
struct NoComponentReuseSceneOnePositiveExample {
  private dataSource: ItemDataSource = new ItemDataSource();

  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: ItemData) => {
          ListItem() {
            NewsContent({ item: item })
          }
        }, (item: ItemData) => item.id.toString())
      }
    }
  }
}

// [Start NoComponentReuseSceneOnePositiveExample]
@Reusable
@Component
struct NewsContent {
  // [StartExclude NoComponentReuseSceneOnePositiveExample]
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

  // [EndExclude NoComponentReuseSceneOnePositiveExample]
}

// [End NoComponentReuseSceneOnePositiveExample]

// [Start ComponentReuseImproperUseSceneTwoPositiveExample]
@Component
struct TopView {
  // [StartExclude ComponentReuseImproperUseSceneTwoPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude ComponentReuseImproperUseSceneTwoPositiveExample]
}

@Component
struct BottomView {
  // [StartExclude ComponentReuseImproperUseSceneTwoPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude ComponentReuseImproperUseSceneTwoPositiveExample]
}

@Component
struct MiddleSingleImageView {
  // [StartExclude ComponentReuseImproperUseSceneTwoPositiveExample]
  @ObjectLink item: ItemData;

  build() {
    // ...
  }

  // [EndExclude ComponentReuseImproperUseSceneTwoPositiveExample]
}

// [End ComponentReuseImproperUseSceneTwoPositiveExample]