
declare interface BreakpointTypeOption<T>{
   xs?: T;
   sm?: T;
   md?: T;
   lg?: T;
   xl?: T;
}

export class BreakpointType<T> {
  options:BreakpointTypeOption<T>;

  public constructor(option: BreakpointTypeOption<T>) {
    this.options = option
  }

  //FAQ:如何解决编译报错“Indexed access is not supported for fields(arkts-no-props-by-index)”的问题
  // [Start IndexedAccess]
  getValue(breakpoint: string): T {
    return Reflect.get(this.options, breakpoint) as T;
  }
  // [End IndexedAccess]
}