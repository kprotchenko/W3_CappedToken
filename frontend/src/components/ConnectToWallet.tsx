import {formatUnits, parseEther} from "viem";
import tokenSaleArtifact from "../../../contracts/out/TokenSale.sol/TokenSale.json";
import {
    useConnect,
    useConnection,
    useDisconnect,
    useReadContract,
    useWaitForTransactionReceipt,
    useWriteContract
} from "wagmi";
import tokenArtifact from "../../../contracts/out/CappedToken.sol/CappedToken.json";
import * as React from "react";
const tokenAddress = import.meta.env.VITE_TOKEN as `0x${string}`
const tokenSaleAddress = import.meta.env.VITE_TOKEN_SALE as `0x${string}`

function ConnectToWallet(){
    const { address, isConnected } = useConnection()
    const { mutate, connectors } = useConnect()
    const { mutate: disconnect } = useDisconnect()
    const { isPending } = useWriteContract()
    // 1) Read token balance + grab refetch function
    const {
        data: tokenBalance,
        refetch: refetchTokenBalance,
    } = useReadContract({
        address: tokenAddress,
        abi: tokenArtifact.abi,
        functionName: "balanceOf",
        args: address ? [address] : undefined,
        // optional, but avoids running before address exists
        query: { enabled: Boolean(address) },
    });
    // 2) Buy tx
    const buyTx = useWriteContract();

    // 3) Wait for the buy tx to be mined
    const { isSuccess: isBuyMined } = useWaitForTransactionReceipt({
        hash: buyTx.data, // wagmi sets this to the tx hash after mutate/mutateAsync
        chainId: 31337,
    });

    // 4) When mined, refetch balance so UI updates
    React.useEffect(() => {
        if (!isBuyMined) return;
        refetchTokenBalance();
    }, [isBuyMined, refetchTokenBalance]);

    const handleBuy = async (money: string) => {
        try {
            await buyTx.mutateAsync({
                address: tokenSaleAddress,
                abi: tokenSaleArtifact.abi,
                functionName: "buy",
                value: parseEther(money),
                chainId: 31337,
            });
        } catch (e) {
            console.error("buy failed", e);
        }
    };
    // const handleBuy = async (money: string) => {
    //     try {
    //         await mutateAsync({
    //             address: tokenSaleAddress,
    //             abi: tokenSaleArtifact.abi,
    //             functionName: 'buy',
    //             value: parseEther(money),
    //             chainId: 31337,
    //         })
    //     } catch (e) {
    //         console.error('buy failed', e)
    //     }
    // }
    // const { data: tokenBalance } = useReadContract ({
    //     address: tokenAddress,
    //     abi: tokenArtifact.abi,
    //     functionName: 'balanceOf',
    //     args: address ? [address] : undefined,
    // })
    return (
        <>
            <div>
                {!isConnected ? (
                    connectors.map((c) => (
                        <button key={c.id} onClick={() => mutate({ connector: c })}>
                            Connect ({c.name?c.name:'unknown'}:{c.id?c.id:'unknown'})
                        </button>
                    ))
                ) : (
                    <>
                        <p>Connected: {address}</p>
                        <button onClick={() => disconnect()}>Disconnect</button>

                        <button onClick={() => handleBuy('0.005')} disabled={isPending}>
                            {isPending ? 'Buying…' : 'Buy 5 CT (0.001 ETH each)'}
                        </button>

                        <p>
                            Token balance:{" "}
                            {tokenBalance ? formatUnits(tokenBalance as bigint, 18) : '0'}
                        </p>
                    </>

                )}
            </div>
        </>
    );
}
export default ConnectToWallet;