@Component
export struct ListItemComponent {
  @Prop myItem: string = ''
  @Prop index: number = 0

  build() {
    Text(`${this.index + 1}. ${this.myItem}`)
      .fontSize(16)
  }
}