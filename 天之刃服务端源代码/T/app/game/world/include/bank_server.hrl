-define(SERVER, mod_bank_server). 
-define(RATES, 0.02).
-define(BUY_REQUEST_LIMITED, 5).
-define(SELL_REQUEST_LIMITED, 5).
-define(TIME_DIFF, 7*24*60*60).

-define(SYSTEMLETTER, 2).
-define(SENDER, "钱庄－沈万三").
-define(BUYERNOTICE, "亲爱的~s\n      恭喜你在钱庄的元宝求购委托(求购数量~w，单价~w两)获得成交，成交数量~w，您获得元宝~w。\n\n<p align=\"right\">钱庄-沈万三</p>").
-define(SELLERNOTICE, "亲爱的~s:\n      恭喜你在钱庄的元宝出售委托(出售数量~w，单价~w两)获得成交，成交数量~w，扣除手续费后，您获得银子").
