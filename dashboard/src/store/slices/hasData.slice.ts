import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface IHasData {
  hasData: boolean;
}

const initialState: IHasData = {
  hasData: false,
};

const hasDataSlice = createSlice({
  name: 'hasData',
  initialState,
  reducers: {
    setHasData: (state, action: PayloadAction<{ hasData: boolean }>) => {
      state.hasData = action.payload.hasData;
    },
  },
});

export const selectsetHasData = (state: RootState): IHasData => state.hasData;

export const { setHasData } = hasDataSlice.actions;
export default hasDataSlice.reducer;
