import { DatabaseHelper } from './DatabaseHelper';

let myHandler = async function (_event, _context, callback, logger) {
  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    const result: string | undefined = await databaseHelper.pushMessage();
    if (result) {
      callback({
        code: 0,
        message: '[push-message] operation successful',
        data: result,
      });
    } else {
      callback({
        code: 1,
        message: '[push-message] operation failed',
        data: null,
      });
    }
  } catch (err) {
    logger.error(`[push-message] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[push-message] operation exception',
      data: err,
    });
  }
};

export { myHandler };