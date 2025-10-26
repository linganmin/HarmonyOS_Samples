// [Start Case1]
@Entry
@Component
struct ReuseType1 {
  // [StartExclude Case1]
  private dataSource: IDataSource = {
    totalCount: () => 0,
    getData: (index: number) => "",
    registerDataChangeListener: () => {
    },
    unregisterDataChangeListener: () => {
    }
  }

  // [EndExclude Case1]
  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: string) => {
          ListItem() {
            CardView({ item: item })
          }
        }, (item: string) => item)
      }
    }
  }
}


// multiplexed component
@Reusable
@Component
export struct CardView {
  @State item: string = '';

  // [StartExclude Case1]
  build() {
    Column() {
    }
  }

  // [StartExclude Case1]
  aboutToReuse(params: Record<string, Object>): void {
    this.item = params.item as string;
  }

  // ...
}

// [End Case1]