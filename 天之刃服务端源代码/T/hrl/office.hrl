-define(OFFICE_ID_MINISTER, 1).
-define(OFFICE_NAME_MINISTER, <<"内阁大臣">>).
-define(OFFICE_EQUIP_MINISTER, 32110102).
-define(OFFICE_ID_GENERAL, 2).
-define(OFFICE_NAME_GENERAL, <<"大将军">>).
-define(OFFICE_EQUIP_GENERAL, 32110103).
-define(OFFICE_ID_JINYIWEI, 3).
-define(OFFICE_NAME_JINYIWEI, <<"锦衣卫指挥使">>).
-define(OFFICE_EQUIP_JINYIWEI, 32110104).

-define(OFFICE_ID_KING, 4).
-define(OFFICE_EQUIP_KING, 32110101).
-define(OFFICE_NAME_KING, <<"国王">>).

-define(OFFICE(OfficeID),
		if
			OfficeID =:= ?OFFICE_ID_MINISTER ->
				{?OFFICE_EQUIP_MINISTER,?OFFICE_NAME_MINISTER};
			OfficeID =:= ?OFFICE_ID_GENERAL ->
				{?OFFICE_EQUIP_GENERAL,?OFFICE_NAME_GENERAL};
			OfficeID =:= ?OFFICE_ID_JINYIWEI ->
				{?OFFICE_EQUIP_JINYIWEI,?OFFICE_NAME_JINYIWEI};
			OfficeID =:= ?OFFICE_ID_KING ->
				{?OFFICE_EQUIP_KING,?OFFICE_NAME_KING};
			true ->
				{0,""}
		end).

-define(OFFICE_EQUIP(OfficeID),
		case ?OFFICE(OfficeID) of
			{Equip,_Name} ->
				Equip;
			_Other ->
				0
		end
		).

-define(OFFICE_NAME(OfficeID),
		case ?OFFICE(OfficeID) of
			{_Equip,Name} ->
				Name;
			_Other ->
				""
		end
	   ).