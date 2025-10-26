export const initRDB: (databaseDir: string) => void;
export const addRDB: (name: string, price: number) => void;
export const searchRDB: () => object;
export const changeRDB: (id: number, name: string, price: number) => void;
export const deleteRDB: (id: number) => void;
export const searchFiltered: (name: string, price: number) => object;
