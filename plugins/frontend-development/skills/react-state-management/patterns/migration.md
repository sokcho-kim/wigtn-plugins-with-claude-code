# Migration from Legacy Redux to RTK

Step-by-step migration guide from legacy Redux patterns.

## Before: Legacy Redux

```typescript
// Old action types
const ADD_TODO = "ADD_TODO";
const TOGGLE_TODO = "TOGGLE_TODO";

// Old action creators
const addTodo = (text) => ({ type: ADD_TODO, payload: text });
const toggleTodo = (id) => ({ type: TOGGLE_TODO, payload: id });

// Old reducer with switch
function todosReducer(state = [], action) {
  switch (action.type) {
    case ADD_TODO:
      return [...state, { id: Date.now(), text: action.payload, completed: false }];
    case TOGGLE_TODO:
      return state.map((todo) =>
        todo.id === action.payload
          ? { ...todo, completed: !todo.completed }
          : todo
      );
    default:
      return state;
  }
}

// Old store setup
import { createStore, combineReducers, applyMiddleware } from "redux";
import thunk from "redux-thunk";

const rootReducer = combineReducers({
  todos: todosReducer,
});

const store = createStore(rootReducer, applyMiddleware(thunk));
```

## After: Redux Toolkit

```typescript
// RTK slice - replaces actions + reducer
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

const todosSlice = createSlice({
  name: "todos",
  initialState: [] as Todo[],
  reducers: {
    addTodo: (state, action: PayloadAction<string>) => {
      // Immer allows "mutations"
      state.push({
        id: Date.now(),
        text: action.payload,
        completed: false,
      });
    },
    toggleTodo: (state, action: PayloadAction<number>) => {
      const todo = state.find((t) => t.id === action.payload);
      if (todo) {
        todo.completed = !todo.completed;
      }
    },
  },
});

export const { addTodo, toggleTodo } = todosSlice.actions;
export default todosSlice.reducer;

// RTK store setup - much simpler
import { configureStore } from "@reduxjs/toolkit";

export const store = configureStore({
  reducer: {
    todos: todosSlice.reducer,
  },
  // Thunk middleware included by default
});
```

## Migration Steps

1. **Install RTK**: `npm install @reduxjs/toolkit`
2. **Convert reducers to slices** one at a time
3. **Replace createStore with configureStore**
4. **Remove action type constants** - createSlice generates them
5. **Use Immer-style "mutations"** in reducers
6. **Replace thunk actions with createAsyncThunk**

## Key Differences

| Legacy Redux | Redux Toolkit |
|--------------|---------------|
| Action type constants | Auto-generated from slice name |
| Immutable spread updates | Immer "mutations" allowed |
| Manual thunk setup | createAsyncThunk included |
| Switch statements | Object reducers |
| combineReducers boilerplate | Single reducer object |
