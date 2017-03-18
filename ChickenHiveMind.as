#include "Logging.as"
#include "ChickenCommon.as"


void onInit(CRules@ this) {
	// Kill all neutral chickens
	CBlob@[] chickens = GetChickens();

	for (int i=0; i < chickens.length; ++i) {
		CBlob@ chicken = chickens[i];

		if (chicken.getTeamNum() == 0 || chicken.getTeamNum() == 1) {
			continue;
		}
		else {
			// CULL IT
			chicken.server_Die();
		}
	}
}

void onTick(CRules@ this) {
    CBlob@[] chickens = GetChickens();
    //log("onTick", "num chickens: " + chickens.length);

    if (getNet().isServer()) {
        if (getGameTime() % EGG_UPDATE_FREQ == 0) {
            LayEggs(chickens);
            HatchEggs();
        }
    }

    for (int i=0; i < chickens.length(); i++) {
        CBlob@ chicken = chickens[i];
        if (getGameTime() % 3 == 0)
            ChickenSpriteTick(chicken.getSprite());
        ChickenBlobTick(chicken);
    }
}

void ChickenSpriteTick(CSprite@ this) {
	CBlob@ blob = this.getBlob();

    if (XORRandom(CHICKEN_SOUND_CHANCE) == 1) {
        this.PlaySound("/Pluck");
    }

	if (!blob.hasTag("dead"))
	{
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (blob.isAttached())
		{
			AttachmentPoint@ ap = blob.getAttachmentPoint(0);
			if (ap !is null && ap.getOccupied() !is null)
			{
				if (Maths::Abs(ap.getOccupied().getVelocity().y) > 0.2f)
				{
					this.SetAnimation("fly");
				}
				else
					this.SetAnimation("idle");
			}
		}
		else if (!blob.isOnGround())
		{
			this.SetAnimation("fly");
		}
		else if (x > 0.02f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			if (this.isAnimationEnded())
			{
				uint r = XORRandom(20);
				if (r == 0)
					this.SetAnimation("peck_twice");
				else if (r < 5)
					this.SetAnimation("peck");
				else
					this.SetAnimation("idle");
			}
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.PlaySound("/ScaredChicken");
	}
}

void ChickenBlobTick(CBlob@ this) {
	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			if (b !is null)
			{
				Vec2f vel = b.getVelocity();
				if (vel.y > 0.5f)
				{
					b.AddForce(Vec2f(0, -20));
				}
			}
		}
	}
	else if (!this.isOnGround())
	{
		Vec2f vel = this.getVelocity();
		if (vel.y > 0.5f)
		{
			this.AddForce(Vec2f(0, -10));
		}
	}
}

void LayEggs(CBlob@[] chickens) {
    for (int i=0; i < chickens.length(); i++) {
        CBlob@ chicken = chickens[i];

        if (XORRandom(LAY_EGG_CHANCE/EGG_UPDATE_FREQ) == 1) {
            //log("LayEggs", "Laying an egg!");

            // Limit the number of eggs that can be laid in a small spot
            CBlob@[] localEggs;
            getMap().getBlobsInRadius(chicken.getPosition(), CHICKEN_LIMIT_RADIUS, @localEggs);
            if (localEggs.length < EGG_LIMIT_LOCAL) {
                float offsetX = XORRandom(6)-3; // prevent eggs spawning on exactly the same spot
                server_CreateBlob("egg", chicken.getTeamNum(), chicken.getPosition() + Vec2f(offsetX, 5));
            }
        }
    }
}


void HatchEggs() {
    CBlob@[] eggs = GetEggs();
    //log("HatchEggs", "num eggs: " + eggs.length);

    for (int i=0; i < eggs.length; ++i) {
        CBlob@ egg = eggs[i];

        if (egg.getTickSinceCreated() > EGG_GROW_TIME) {
            // Copied from Egg.as
            int chickenCount = 0;
            CBlob@[] blobs;
            getMap().getBlobsInRadius(egg.getPosition(), CHICKEN_LIMIT_RADIUS, @blobs);
            for (uint step = 0; step < blobs.length; ++step)
            {
                CBlob@ other = blobs[step];
                if (other.getName() == "chicken")
                {
                    chickenCount++;
                }
            }

            if (chickenCount < CHICKEN_LIMIT_LOCAL)
            {
                //log("HatchEggs", "Hatching a chicken!");
                egg.SendCommand(egg.getCommandID("hatch"));
            }
        }
    }
}