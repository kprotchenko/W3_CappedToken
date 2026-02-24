import './App.css'
import "bootstrap/dist/css/bootstrap.css";
import Alert from "./components/Alert.tsx";
import Button from "./components/Button.tsx";
import ListGroup from "./components/ListGroup.tsx";
import ConnectToWallet from "./components/ConnectToWallet.tsx";

import { useState } from "react";

let items = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Toronto',
    'Tokyo'
];
const handleSelect = (item: string) => {
    console.log(item);
}

function App() {
    const [showAlert, setShowAlert] = useState(false)
    return <>

        {showAlert && <div><Alert onClose={() => {
            // handleClose();
            setShowAlert(false);
        }}>Hello <span>World!!!</span></Alert></div>}

        <div><Button
            onClick={ () => {
                // handleClick();
                setShowAlert(true);
            }}
            type="primary">My Button</Button></div>

        <div id="liveAlertPlaceholder"></div>
        <button type="button" className="btn btn-primary" id="liveAlertBtn">Show live alert</button>
        <ListGroup items={items} header="Cities" onSelect={handleSelect}/>
        <ConnectToWallet/>

    </>;
}

export default App;
