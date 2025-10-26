/**
 * FAQ:如何使用正则表达式
 */
// [Start new_reg]
const reg = new RegExp('ba');
// [End new_reg]

// [Start reg_test]
const res = reg.test('bar');
console.info('result', res);
// [End reg_test]