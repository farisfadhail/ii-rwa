import Actors from "./services/Actors";
import App from "./App";
import { InternetIdentityProvider } from "ic-use-internet-identity";
import React from "react";
import ReactDOM from "react-dom/client";
import { Toaster } from "react-hot-toast";

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<InternetIdentityProvider>
			<Actors>
				<App />
				<Toaster position="bottom-right" containerClassName="font-sans text-4xl italic" />
			</Actors>
		</InternetIdentityProvider>
	</React.StrictMode>
);
