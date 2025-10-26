
const baseChar: string[] = (() => {
  const array: string[] = [];
  // Add numbers 0 - 9 to baseChar
  for (let i = 0; i < 10; i++) {
    array.push(i.toString(10));
  }
  // Add lowercase letters a-z to baseChar
  for (let i = 0; i < 26; i++) {
    array.push(String.fromCharCode('a'.charCodeAt(0) + i));
  }
  // Add uppercase letters A-Z to baseChar
  for (let i = 0; i < 26; i++) {
    array.push(String.fromCharCode('A'.charCodeAt(0) + i));
  }
  return array;
})();

// Set of UUID parameters. You can use count to ensure that UUIDs are unique in the local environment.
const UuidObject: Record<string, { prefix: string; count: number }> = {};

export class UuidBasic{

  // Number conversion/digit conversion
  private static scaleTransition(value: number, base = baseChar): string {
    if (value < 0) {
      throw new Error('scaleTransition Error, value < 0');
    }
    if (value === 0) {
      return base[0];
    }
    const radix = base.length;
    let result = '';
    let resValue = value;
    while (resValue > 0) {
      result = base[resValue % radix] + result;
      resValue = Math.floor(resValue / radix);
    }
    return result;
  }


  // Generate a random UUID
  public static createUUID(prefix = '') {
    let uuidObject = UuidObject[prefix];
    if (uuidObject === undefined) {
      const str = `${this.scaleTransition(Date.now())}-${this.scaleTransition(
        Math.floor(Math.random() * 10000000000),
      )}-`;
      if (prefix) {
        uuidObject = {
          prefix: `${prefix}-${str}`,
          count: 0,
        };
      } else {
        uuidObject = {
          prefix: str,
          count: 0,
        };
      }
      UuidObject[prefix] = uuidObject;
    }
    return uuidObject.prefix + this.scaleTransition(uuidObject.count++);
  }
}