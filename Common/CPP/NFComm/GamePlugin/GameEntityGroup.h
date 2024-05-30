#ifndef GAMEENTITYGROUP_H
#define GAMEENTITYGROUP_H

#include <map>
#include <memory>

#include "NFComm/NFPluginModule/NFGUID.h"
#include "GameAction.h"


class GameEntity
{
public:
	const NFGUID id;

	virtual bool CanExcuteAction(E_GAME_ACTION action) const { return false; };

	virtual void ExcuteAction(E_GAME_ACTION action);
};

class GameEntityGroup: public GameEntity
{
public:
	using GameEntityType = shared_ptr<GameEntity>;

	virtual void Join(GameEntityType entity);
	virtual void Leave(GameEntityType entity);


	std::map<NFGUID, GameEntityType> mEntities;
};

#endif