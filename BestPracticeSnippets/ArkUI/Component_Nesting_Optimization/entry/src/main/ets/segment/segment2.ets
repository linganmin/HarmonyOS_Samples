@Component
struct FlowListStruct {
  build() {
  }
}

// [Start Counter_example1]
@Component
export struct Example {
  build() {
    Column() {
      // Custom Components
      FlowListStruct(
        // Custom Component Passing Parameters
        // ...
      ).backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
  }
}

// [End Counter_example1]

// [Start Case1]
@Component
export struct FlowListStruct2 {
  build() {
    Column() {
      // ...
    }
    .backgroundColor('#FFFFFF')
  }
}

// [End Case1]

// [Start Case2]
@Entry
@Component
struct CustomComponentModifier {
  modifier: ColumnModifier = new ColumnModifier();

  aboutToAppear(): void {
    this.modifier.width = 100;
    this.modifier.height = 100;
    this.modifier.backgroundColor = Color.Red;
  }

  build() {
    Column() {
      ModifierCustom({ modifier: this.modifier })
    }
  }
}


@Component
struct ModifierCustom {
  @Require @Prop modifier: AttributeModifier<ColumnAttribute>;

  build() {
    Column() {
      Text('Hello Word')
    }.attributeModifier(this.modifier)
  }
}

// When using dynamic attribute setting, you need to inherit AttributeModifier, implement a Modifier by yourself, and then set it to the required component.
class ColumnModifier implements AttributeModifier<ColumnAttribute> {
  width: number = 0;
  height: number = 0;
  backgroundColor: ResourceColor | undefined = undefined;

  applyNormalAttribute(instance: ColumnAttribute): void {
    instance.width(this.width);
    instance.height(this.height);
    instance.backgroundColor(this.backgroundColor);
  }
}

// [End Case2]

