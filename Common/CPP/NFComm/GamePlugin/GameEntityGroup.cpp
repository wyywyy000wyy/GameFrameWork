#include "GameEntityGroup.h"


void GameEntityGroup::Join(GameEntityType entity)
{
	mEntities[entity->id] = entity;
}

void GameEntityGroup::Leave(GameEntityType entity)
{
	mEntities.erase(entity->id);
}

void GameEntity::ExcuteAction(E_GAME_ACTION action)
{
	
}
