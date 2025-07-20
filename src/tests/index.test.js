import React from "react";
import ReactDOM from "react-dom/client";
import App from "../src/components/App";
import { Provider } from "react-redux";
import { createStore } from "redux";
import rootReducer from "../src/reducers";

it("renders App without crashing", () => {
  const store = createStore(rootReducer);
  const div = document.createElement("div");

  ReactDOM.createRoot(div).render(
    <Provider store={store}>
      <App />
    </Provider>
  );
});
