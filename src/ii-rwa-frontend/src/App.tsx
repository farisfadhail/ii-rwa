import { useEffect, useState } from "react";

import { LoginButton } from "./components/LoginButton";
import Principal from "./components/Principal";
import { useBackend } from "./services/Actors";
import { useInternetIdentity } from "ic-use-internet-identity";

function App() {
	const { identity } = useInternetIdentity();
	const { actor: backend } = useBackend();
	const [principal, setPrincipal] = useState<string>();
	const [greeting, setGreeting] = useState<string>();
	const [message, setMessage] = useState<string>();
	const [user, setUser] = useState<string>();
	const [lands, setLands] = useState<string>();
	const [land, setLand] = useState<string>();

	function handleGreeting(event: React.FormEvent<HTMLFormElement>) {
		event.preventDefault();
		const name = (event.currentTarget.elements.namedItem("name") as HTMLInputElement).value;
		if (backend) {
			backend.greet(name).then((greeting) => {
				setGreeting(greeting.toString());
			});
		}
		return false;
	}

	function handleRegister(event: React.FormEvent<HTMLFormElement>) {
		event.preventDefault();
		const nik = (event.currentTarget.elements.namedItem("nik") as HTMLInputElement).value;
		if (backend) {
			backend.registerUser(BigInt(nik)).then((result) => {
				const [code, message, user] = result;
				if (Number(code) === 200) {
					if (user && user[0]) {
						setUser(user[0].toString());
						setMessage(message);
					}
				} else {
					setMessage("Registration failed");
				}
			});
		}
		return false;
	}

	useEffect(() => {
		if (backend) {
			backend.getUserByPrincipal().then((user) => {
				setUser(JSON.stringify(user, (key, value) => (typeof value === "bigint" ? value.toString() : value), 2));
			});
		}
	}, [backend]);

	function handleGetUser(event: React.FormEvent<HTMLFormElement>) {
		event.preventDefault();
		if (backend) {
			backend.getUserByPrincipal().then((user) => {
				setUser(JSON.stringify(user, (key, value) => (typeof value === "bigint" ? value.toString() : value), 2));
			});
		}
		return false;
	}

	function handleGetLands(event: React.FormEvent<HTMLFormElement>) {
		event.preventDefault();
		if (backend) {
			backend.getLands().then((lands) => {
				setLands(JSON.stringify(lands, (key, value) => (typeof value === "bigint" ? value.toString() : value), 2));
			});
		}
		return false;
	}

	function handleAddLand(event: React.FormEvent<HTMLFormElement>) {
		event.preventDefault();
		const certificate_id = (event.currentTarget.elements.namedItem("certificate_id") as HTMLInputElement).value;
		const price = (event.currentTarget.elements.namedItem("price") as HTMLInputElement).value;
		if (backend) {
			backend.registerLand(certificate_id, BigInt(price)).then((result) => {
				const [code, message, land] = result;
				if (Number(code) === 200) {
					if (land && land[0]) {
						setLand(JSON.stringify(land, (key, value) => (typeof value === "bigint" ? value.toString() : value), 2));
						setMessage(message);
					}
				} else {
					setMessage("Land registration failed");
				}
			});
		}
		return false;
	}

	useEffect(() => {
		if (!identity) setPrincipal("");
	}, [identity]);

	useEffect(() => {
		if (identity && backend && !principal) {
			backend.whoami().then((p) => setPrincipal(p.toString()));
		}
	}, [backend, identity, principal]);

	return (
		<main>
			<img src="/logo2.svg" alt="DFINITY logo" />
			<br />
			<br />
			<form action="#" onSubmit={handleGreeting}>
				<label htmlFor="name">Enter your name: &nbsp;</label>
				<input id="name" alt="Name" type="text" />
				<button type="submit">Click Me!</button>
			</form>
			<section id="greeting">Greeting: {greeting}</section>
			<section id="message">Message: {message}</section>
			{/* <section id="user">User: {user ? JSON.stringify(JSON.parse(user).principal.__principal__, null, 2) : "No user data available"}</section> */}
			<section id="user">User: {user ? JSON.stringify(JSON.parse(user), null, 2) : "No user data available"}</section>
			<section id="land">Land: {land ? JSON.stringify(JSON.parse(land), null, 2) : "No land data available"}</section>
			<section id="lands">Lands: {lands ? JSON.stringify(JSON.parse(lands), null, 2) : "No lands data available"}</section>
			<section id="principal">Principal: {principal}</section>
			<br />
			<br />
			<div className="flex flex-col items-center w-full gap-5 p-10 font-sans text-2xl italic md:items-start md:gap-10 md:text-6xl">
				<div className="text-center">{identity ? "You are logged in." : "You are not logged in."}</div>
				<LoginButton />
				{identity ? <Principal principal={principal} /> : <Principal principal="2vxsx-fae" />}
			</div>
			<br />
			<br />
			{identity ? (
				backend ? (
					<>
						{user && user.toString().includes(identity.getPrincipal().toText()) ? (
							<>
								<form action="#" onSubmit={handleGetUser}>
									<button type="submit">Get User Detail</button>
								</form>

								<form action="#" onSubmit={handleAddLand}>
									<label htmlFor="certificate_id">Enter your ID Certificate: &nbsp;</label>
									<input id="certificate_id" alt="certificate_id" type="text" />
									<label htmlFor="price">Enter your Price: &nbsp;</label>
									<input id="price" alt="price" type="text" pattern="\d*" />
									<button type="submit">Add Your Land</button>
								</form>

								<form action="#" onSubmit={handleGetLands}>
									<button type="submit">Get Lands</button>
								</form>
							</>
						) : (
							<form action="#" onSubmit={handleRegister}>
								<label htmlFor="nik">Enter your NIK: &nbsp;</label>
								<input id="nik" alt="nik" type="text" pattern="\d*" />
								<button type="submit">Register</button>
							</form>
						)}
					</>
				) : (
					"Loading..."
				)
			) : (
				"Unauthorized"
			)}

			{identity ? "" : "Unauthorized"}
		</main>
	);
}

export default App;
