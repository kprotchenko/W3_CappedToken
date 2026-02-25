import {formatUnits, parseEther, getAddress} from "viem";
import tokenSaleArtifact from "../../../contracts/out/TokenSale.sol/TokenSale.json";
import {
    useBalance,
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
const ANVIL_CHAIN_ID = 31337 as const

function ConnectToWallet(){
    const { address, isConnected } = useConnection()
    const { mutate, connectors } = useConnect()
    const { mutate: disconnect } = useDisconnect()
    const { isPending } = useWriteContract()

    // --- ETH (native) balance ---
    const {
        data: ethBalance,
        refetch: refetchEthBalance,
    } = useBalance({
        address,
        chainId: ANVIL_CHAIN_ID,
    }) // :contentReference[oaicite:3]{index=3}

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
        chainId: ANVIL_CHAIN_ID,
    });

    // 4) When mined, refetch balance so UI updates
    React.useEffect(() => {
        if (!isBuyMined) return
        refetchTokenBalance()
        refetchEthBalance()
    }, [isBuyMined, refetchEthBalance, refetchTokenBalance]);

    const handleBuy = async (money: string) => {
        try {
            await buyTx.mutateAsync({
                address: tokenSaleAddress,
                abi: tokenSaleArtifact.abi,
                functionName: "buy",
                value: parseEther(money),
                chainId: ANVIL_CHAIN_ID,
            });
        } catch (e) {
            console.error("buy failed", e);
        }
    };

    // ...
    const { data: saleOwner } = useReadContract({
        address: tokenSaleAddress,
        abi: tokenSaleArtifact.abi,
        functionName: 'owner',
        chainId: ANVIL_CHAIN_ID,
        query: { enabled: Boolean(address) },
    })

    const isOwner =
        Boolean(address && saleOwner) &&
        getAddress(address!) === getAddress(saleOwner as `0x${string}`)
    const handleWithdrawFunds = async () => {
        try {
            await buyTx.mutateAsync({
                address: tokenSaleAddress,
                abi: tokenSaleArtifact.abi,
                functionName: "withdrawFunds",
                chainId: ANVIL_CHAIN_ID,
            });
        } catch (e) {
            console.error("withdrawFunds failed", e);
        }
    }
    const handleWithdrawTokens = async () => {
        try {
            await buyTx.mutateAsync({
                address: tokenSaleAddress,
                abi: tokenSaleArtifact.abi,
                functionName: "withdrawTokens",
                chainId: ANVIL_CHAIN_ID,
            });
        } catch (e) {
            console.error("withdrawTokens failed", e);
        }
    }
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
                        <div>
                            ETH balance:{' '}
                            {ethBalance
                                ? `${formatUnits(ethBalance.value, ethBalance.decimals)} ${ethBalance.symbol}`
                                : '—'}
                        </div>
                        <div>
                            Token balance:{" "}
                            {tokenBalance ? formatUnits(tokenBalance as bigint, 18) : '0'}
                        </div>
                        {isOwner ? (
                            <section>
                                <h3>Owner actions</h3>
                                <button onClick={handleWithdrawFunds}>Withdraw ETH</button>
                                <button onClick={handleWithdrawTokens}>Withdraw tokens</button>
                            </section>
                        ) : (
                            <div style={{ opacity: 0.7 }}>
                                Connected account is not the owner (owner: {String(saleOwner ?? '—')}).
                            </div>
                        )}
                    </>

                )}
            </div>
        </>
    );
}
export default ConnectToWallet;