#ifndef GAMEACTION_H
#define GAMEACTION_H
#include <unordered_map>
#include "NFComm/NFPluginModule/NFGUID.h"

enum E_GAME_ACTION
{
	NONE,
};

class GameAction
{
public:
	NFGUID id;
	NFGUID actorId;

	//virtual GAME_ACTION Action() const { return GAME_ACTION::NONE; }
};

#endif // !GAMEACTION_H
