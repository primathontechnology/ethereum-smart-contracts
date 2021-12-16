# ICO Smart Contract

An Initial Coin Offering (ICO) is a type of crowdfunding using cryptocurrencies;
- An ICO can be a source of capital for startup companies that offers investors some
units of a new cryptocurrency or crypto-token in exchange for a well-known and valuable
cryptocurrency like Ethereum;
- The first ICO (also known as token-sale) was held by Mastercoin in July 2013. The
Ethereum project raised money with a token-sale in 2014, as well. It raised 3,700 BTC in
the first 12 hours.
- Who can launch an ICO? *Literally anyone!*
- Before launching an ICO it’s mandatory to verify and obey the laws of the countries your
investors are coming from! For example China banned ICOs calling them illegal
fundraising. Also note that the vast majority of ICOs have failed.



# ICO Problem Statement and Specs

Our ICO will be a Smart Contract that accepts ETH in exchange for our own token named
Cryptos (PMTN);
- The Cryptos token is a fully compliant ERC20 token and will be generated at the ICO time;
- Investors will send ETH to the ICO contract’s address and in return, they’ll get an amount of
Cryptos;
- There will be a deposit address (EOA account) that automatically receives the ETH sent to
the ICO contract;
- PMTN token price in wei is: 1PMTN = 0.001Eth = 10**15 wei, 1Eth = 1000 PMTN);
- The minimum investment is 0.01 ETH and the maximum investment is 5 ETH;
- The ICO Hardcap is 300 ETH;
- The ICO will have an admin that specifies when the ICO starts and ends;
- The ICO ends when the Hardcap or the end time is reached (whichever comes first);
- The PMTN token will be tradable only after a specific time set by the admin;
- In case of an emergency the admin could stop the ICO and could also change the deposit
address in case it gets compromised;
- The ICO can be in one of the following states: beforeStart, running, afterEnd, halted;
- And we’ll also implement the possibility to burn the tokens that were not sold in the ICO;
- After an investment in the ICO the Invest event will be emitted;

