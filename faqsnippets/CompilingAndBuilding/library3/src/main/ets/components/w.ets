// FAQ:构建报错"Cannot read properties of undefined(reading 'XXX')"
// [Start CorrectWriting]
// Correct writing
class w {
  public a: string[][] = []
  test() {
    console.log("1", this.a[0])
  }
}
// [End CorrectWriting]