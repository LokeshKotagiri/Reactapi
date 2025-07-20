import React from "react";
import ReactDOM from "react-dom";
import App from "../components/App";
import { Provider } from "react-redux";
import { createStore } from "redux";
import rootReducer from "../reducers";

it("renders App without crashing", () => {
  const store = createStore(rootReducer);
  const div = document.createElement("div");

  ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  div
);
});
