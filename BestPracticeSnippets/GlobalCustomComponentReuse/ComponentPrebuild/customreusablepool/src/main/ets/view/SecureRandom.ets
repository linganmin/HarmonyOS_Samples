

export class SecureRandom {
  int: number = 0
  constructor() {
    this.int = 1
  }
  nextInt(int: number): number {
    return int + 1
  }
}