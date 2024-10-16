# Corti X7 Small Accounts

## Overview
Corti X7 Small Accounts is a trading robot designed to work with small accounts. This Expert Advisor (EA) is implemented in MQL4 for use on the MetaTrader 4 platform. It is designed for users looking to leverage algorithmic trading for small investment accounts, providing efficient and automated trading strategies.

## Features
- **Automated Trading:** Executes trades automatically based on predefined technical indicators and logic.
- **Small Account Friendly:** Designed specifically for small account sizes, minimizing risk exposure.
- **Combination of Indicators:** Uses stochastic, EMA (Exponential Moving Average), and RSI (Relative Strength Index) for trade entries and risk management.
- **Customizable Settings:** Users can adjust various parameters to suit their trading needs and risk appetite.

## Installation
1. Copy the `Corti-X7.mq4` file to your MetaTrader 4 `Experts` directory. Typically, the path is:
   ```
   C:\Program Files (x86)\MetaTrader 4\MQL4\Experts
   ```
2. Restart MetaTrader 4 to load the Expert Advisor.
3. In the "Navigator" panel, find `Corti X7 ` under "Expert Advisors" and drag it onto your preferred trading chart.

## Configuration
- **Lot Size:** Set the initial lot size for trades. Recommended starting lot size for small accounts is 0.01.
- **Stop Loss & Take Profit:** Configure stop loss and take profit levels to control risk and secure profits.
- **Indicators Settings:** Adjust stochastic, EMA, and RSI settings as needed to fine-tune the strategy.
- **Risk Management:** Ensure that you configure the EA to manage risk according to your account size and comfort level.

## Usage
- **Chart Timeframe:** This EA works best on M15 or H1 timeframes. Apply it to your preferred currency pair and timeframe.
- **Live & Demo Accounts:** It is recommended to test the EA on a demo account first to understand its behavior before going live.
- **Backtesting:** Use the MetaTrader 4 Strategy Tester to backtest and fine-tune the parameters before deploying it in a live trading environment.

## Notes
- **Risk Warning:** Trading forex and CFDs is highly risky. Corti X7 Small Accounts is intended for use by individuals with experience in forex trading and understanding of risk management.
- **Support & Updates:** Regular updates will be made to improve performance and adapt to market changes.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer
The author is not responsible for any financial losses incurred when using this EA. Use it at your own risk, and trade responsibly.

## Contributing
Pull requests are welcome. For significant changes, please open an issue first to discuss what you would like to change.

