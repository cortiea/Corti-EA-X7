=+= Installation

- Place Corti-X6 Demo.ex4 MQL4/Experts folder.
- Show only FX Major and Minor in MT4 Market Watch.
- Add Corti in a random Chart/TF and wait till it autoscans the Market Watch listed pairs to find
  the most highly correlated dual pairs.
- It will open and hedge them . Adjust lot and trail based on your balance.

- Scanner Mode Default - Scans Top Negative/Positive Correlation.
- Scanner Mode Focus - Focus Pair is EURUSD for example, will scan its top Correlated + or - and will scan the consecutive pair too , till the number of combos you choose.

=+= Inputs Explanation :

- Maximum combos to trade = 6 , it will trade 6 combos or less . 1 Combo = 2 correlated pairs in default mode. In focus mode means one pair.
- InitialLot=0.01;//First Lot of each order for both sides.
- StepLot=0.01;//Step Lot for the recovery orders (0 - disabled , means the recovery orders will open with Initial Lot.
- TrailStep=5;//Trail Profit of the side floating in positive.
- Average Mode : Trail Step (equity) - Trail of the Recovery side,which on lock will close the other side.
- RecoveryCoefficient=2;//Coeficent Equity to trigger Limit Order Distance.
- MaxRecoveries=9;//Max Step Orders to recover : (0 = unlimited)

Follow Corti in :
Official Discord Channel : https://discord.gg/5FDYYjaz3r
Official Telegram Channel : https://t.me/cortiea
Facebook Page :https://www.facebook.com/cortiexpertadvisor
Facebook Private Group : https://www.facebook.com/groups/cortieacom
Instagram Page : https://www.instagram.com/cortiexpertadvisor/
