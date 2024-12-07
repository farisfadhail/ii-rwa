import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
    type User = {
        id: Nat;
        principal: Principal;
        nik: Nat;
        balance: Nat;
    };

    stable var users: [User] = [];
    stable var nextUserId: Nat = 1;

    type Land = {
        id: Nat;           
        certifcate_id: Text;       
        owner: Principal;         
        price: Nat;               
        forSale: Bool;            
    };

    stable var lands: [Land] = [];
    stable var nextLandId: Nat = 1;

    type EventLog = {
        landId: Nat;
        seller: Principal;
        buyer: Principal;
        price: Nat;
        timestamp: Int;
    };

    var transactionLogs: [EventLog] = [];

    public shared(msg) func registerUser(nik: Nat) : async (Nat, Text, ?User) {
        let caller = msg.caller;
        if (Nat.toText(nik).size() != 16) {
            return (400, "NIK is invalid", null);
        };
        if (Array.filter<User>(users, func (user) = user.principal == caller).size() > 0) {
            return (409, "User already registered", null);
        };
        let user = { id = nextUserId; principal = caller; nik = nik; balance = 1000 };
        users := Array.append(users, [user]);
        nextUserId += 1;
        return (200, "User registered", ?user);
    };

    public shared(msg) func authenticateUser(nik: Nat) : async (Nat, Text) {
        let caller = msg.caller;
        for (user in users.vals()) {
            if (user.principal == caller and user.nik == nik) {
                return (200, "User authenticated");
            }
        };
        return (500, "Authentication failed");
    };

    public query func getUsers() : async [User] {
        return users;
    };

    public query func getUserByPrincipal(principal: Text) : async User {
    // public shared(msg) func getUserByPrincipal() : async User {
        let principalParsed = Principal.fromText(principal);
        for (user in users.vals()) {
            // if (user.principal == msg.caller) {
            if (user.principal == principalParsed) {
                return user;
            }
        };
        return { id = 0; principal = Principal.fromText("2vxsx-fae"); nik = 0; balance = 0 };
    };

    public func getUserById(id : Nat) : async User {
        for (user in users.vals()) {
            if (user.id == id) {
                return user;
            }
        };
        return { id = 0; principal = Principal.fromText("2vxsx-fae"); nik = 0; balance = 0 };
    };

    public query func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    public shared (msg) func whoami() : async Principal {
        msg.caller
    };

    public shared(msg) func registerLand(certifcate_id: Text, price: Nat): async (Nat, Text, ?Land) {
        let caller = msg.caller;
        // if (caller == Principal.fromText("2vxsx-fae")) {
        //     return (403, "Unauthorized", null);
        // };

        if (Array.filter<Land>(lands, func (land) = land.certifcate_id == certifcate_id).size() > 0) {
            return (409, "Land already registered", null);
        };

        let newLand = {
            id = nextLandId;
            certifcate_id = certifcate_id;
            owner = caller;
            price = price;
            forSale = false;
        };

        lands := Array.append(lands, [newLand]);
        nextLandId += 1;
        return (200, "Land successfully registered.", ?newLand);
    };

    public shared(msg) func setLandForSale(land_id: Nat, forSale: Bool) : async (Nat, Text, ?Land) {
        let _caller = msg.caller;
        var land = await getLandById(land_id);

        // if (land.owner != caller) {
        //     return (403, "Unauthorized.", null);
        // };
        if (land.id == 0) {
            return (400, "Land not found.", null);
        };
        land := { land with forSale = forSale };

        lands := Array.map<Land, Land>(lands, func (l) {
            if (l.id == land.id) {
                land
            } else {
                l
            }
        });

        return (200, "Land's for sale status has been changed.", ?land);
    };

    // public query func getLands() : async [Land] {
    public shared (_msg) func getLands() : async [Land] {
        // return lands;
        return Array.filter<Land>(lands, func (land) = land.forSale == true);
    };

    // public query func getLandById(land_id: Nat) : async Land {
    public shared (_msg) func getLandById(land_id: Nat) : async Land {
        for (land in lands.vals()) {
            if (land.id == land_id) {
                return land;
            }
        };
        return { id = 0; certifcate_id = ""; owner = Principal.fromText("2vxsx-fae"); price = 0; forSale = false };
    };

    // public query func deleteLand(land_id: Nat) : async (Nat, Text) {
    public shared (msg) func deleteLand(land_id: Nat) : async (Nat, Text) {
        let _caller = msg.caller;

        for (land in lands.vals()) {
            if (land.id == land_id and land.owner == msg.caller) {
                if (land.id == land_id) {
                    return (200, "Land has been deleted.");
                } else {
                    return (400, "Land not found.");
                }
            };
        };

        return (400, "Land not found.");
    };

    // public shared func buyLand(land_id: Nat) : async (Nat, Text) {
    public shared (msg) func buyLand(land_id: Nat) : async (Nat, Text, ?EventLog) {
        let caller = msg.caller;
        var land = await getLandById(land_id);
        if (land.owner == caller) {
            return (400, "You can't buy your own land.", null);
        };
        if (land.id == 0) {
            return (400, "Land not found.", null);
        };
        if (land.forSale == false) {
            return (400, "Land is not for sale.", null);
        };
        var buyer = await getUserByPrincipal(Principal.toText(caller));
        // var buyer = await getUserById(1);
        if (buyer.id == 0) {
            return (400, "User not found.", null);
        };
        if (buyer.nik == 0) {
            return (400, "User not authenticated.", null);
        };
        if (buyer.balance < land.price) {
            return (400, "Insufficient balance.", null);
        };
        var seller = await getUserByPrincipal(Principal.toText(land.owner));
        if (seller.id == 0) {
            return (400, "Seller not found.", null);
        };
        if (seller.nik == 0) {
            return (400, "Seller not authenticated.", null);
        };
        seller := { seller with balance = seller.balance + land.price };
        buyer := { buyer with balance = Nat.sub(buyer.balance, land.price) };

        users := Array.map<User, User>(users, func (user) {
            if (user.principal == seller.principal) {
                seller
            } else if (user.principal == buyer.principal) {
                buyer
            } else {
                user
            }
        });

        land := { land with owner = buyer.principal };
        land := { land with forSale = false };

        lands := Array.map<Land, Land>(lands, func (l) {
            if (l.id == land.id) {
                land
            } else {
                l
            }
        });

        let order = { landId = land_id; seller = seller.principal; buyer = buyer.principal; price = land.price; timestamp = Time.now() };

        transactionLogs := Array.append(transactionLogs, [order]);
        return (200, "Land has been bought.", ?order);
    };

    public query func getTransactionLogs() : async [EventLog] {
        return transactionLogs;
    };
};