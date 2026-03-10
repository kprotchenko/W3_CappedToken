import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { WagmiProvider, createConfig, http } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import App from './App'
import { sepolia } from 'wagmi/chains'  // Wagmi v2 provides a sepolia chain

const queryClient = new QueryClient()


const config = createConfig({
    chains: [sepolia],
    transports: {
        [sepolia.id]: http(import.meta.env.VITE_SEPOLIA_RPC_URL), // your Alchemy/Infura RPC
    },
})

createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <QueryClientProvider client={queryClient}>
            <WagmiProvider config={config}>
                <App />
            </WagmiProvider>
        </QueryClientProvider>
    </StrictMode>,
)
