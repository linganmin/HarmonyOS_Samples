import { BreakpointConstants } from '../constants/BreakpointConstants';

export class BreakpointType<T> {
  private sm: T;
  private md: T;
  private lg: T;

  constructor(sm: T, md: T, lg: T) {
    this.sm = sm;
    this.md = md;
    this.lg = lg;
  }

  public getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      return this.md;
    }
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      return this.lg;
    }
    return this.sm;
  }
}

// Padding and margin of the breakpoint.
export const BREAK_POINT_TYPE_MARGIN_VP: BreakpointType<number> =
  new BreakpointType<number>(BreakpointConstants.CONTAINER_MARGIN_SM, BreakpointConstants.CONTAINER_MARGIN_MD,
    BreakpointConstants.CONTAINER_MARGIN_LG);