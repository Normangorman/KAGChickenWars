#include "Logging.as"


void onInit(CBlob@ this) {
	//for flesh hit
	this.set_f32("gib health", -0.0f);
	this.Tag("flesh");
	this.getShape().SetOffset(Vec2f(0, 6));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData) {
	log("onHit", "damage: " + damage + ", health: " + this.getHealth());
	this.getSprite().PlaySound("/ScaredChicken");
	return damage;
}