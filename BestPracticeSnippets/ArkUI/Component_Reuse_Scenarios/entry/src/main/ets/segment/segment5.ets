// [Start Case5]
@Entry
@Component
struct ReuseType5A {
  // [StartExclude Case5]
  private dataSource: IDataSource = {
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

  // [EndExclude Case5]
  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: number) => {
          ListItem() {
            if (item % 2 === 0) { // Simulation of type I conditions
              ReusableComponent({ item: item })
                .reuseId('type1')
            } else if (item % 3 === 0) { // Simulation of type II conditions
              ReusableComponent({ item: item })
                .reuseId('type2')
            } else { // Simulation of type III conditions
              ReusableComponent({ item: item })
                .reuseId('type3')
            }
          }
        }, (item: number) => item.toString())
      }
    }
  }
}


// multiplexed component
@Reusable
@Component
struct ReusableComponent {
  @State item: number = 0;

  build() {
    Column() {
      ComponentA()
      if (this.item % 2 === 0) {
        ComponentB1()
      } else if (this.item % 3 === 0) {
        ComponentB2()
      } else {
        ComponentB3()
      }
    }
  }
}


@Component
struct ComponentA {
  // [StartExclude Case5]
  build() {
    Column() {
    }
  }

  // [EndExclude Case5]
}


@Component
struct ComponentB1 {
  build() {
    Column() {
      ComponentC()
    }
  }
}


@Component
struct ComponentB2 {
  build() {
    Column() {
      ComponentD()
    }
  }
}


@Component
struct ComponentB3 {
  build() {
    Column() {
      ComponentE()
    }
  }
}


@Component
struct ComponentC {
  // [StartExclude Case5]
  build() {
    Column() {
    }
  }

  // [EndExclude Case5]
}


@Component
struct ComponentD {
  // [StartExclude Case5]
  build() {
    Column() {
    }
  }

  // [EndExclude Case5]
}


@Component
struct ComponentE {
  // [StartExclude Case5]
  build() {
    Column() {
    }
  }

  // [EndExclude Case5]
}

// [End Case5]