#include "Logging.as"

const int grow_time = 50 * getTicksASecond();
const int MAX_CHICKENS_TO_HATCH = 5;
const f32 CHICKEN_LIMIT_RADIUS = 120.0f;

void onInit(CBlob@ this)
{
	this.addCommandID("hatch");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob) {
	return blob.hasTag("wooden");
}


/* Moved to ChickenHiveMind
void onTick(CBlob@ this)
{
	if (getNet().isServer() && this.getTickSinceCreated() > grow_time)
	{
		int chickenCount = 0;
		CBlob@[] blobs;
		this.getMap().getBlobsInRadius(this.getPosition(), CHICKEN_LIMIT_RADIUS, @blobs);
		for (uint step = 0; step < blobs.length; ++step)
		{
			CBlob@ other = blobs[step];
			if (other.getName() == "chicken")
			{
				chickenCount++;
			}
		}

		if (chickenCount < MAX_CHICKENS_TO_HATCH)
		{
			this.SendCommand(this.getCommandID("hatch"));
		}
	}
}
*/


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("hatch"))
	{
		CSprite@ s = this.getSprite();
		if (s !is null)
		{
			s.Gib();
		}

		if (getNet().isServer())
		{
			this.server_SetHealth(-1);
			this.server_Die();
			server_CreateBlob("chicken", this.getTeamNum(), this.getPosition() + Vec2f(0, -5.0f));
		}
	}
}
