#include "CTF_Structs.as";
#include "ChickenCommon.as";
#include "Logging.as";
#include "Hitters.as";

const SColor TEAM0COLOR(255,25,94,157);
const SColor TEAM1COLOR(255,192,36,36);
const int FONT_SIZE = 20;

ChickenCountLabel[] CHICKEN_COUNT_LABELS;

class ChickenCountLabel {
	int count;
	int teamNum;
	Vec2f pos;
}

void onInit(CRules@ this) {
	this.set_u16("chicken count team0", 0);
	this.set_u16("chicken count team1", 0);
	this.set_u16("egg count team0", 0);
	this.set_u16("egg count team1", 0);

    if (!GUI::isFontLoaded("score font")) {
        GUI::LoadFont("score font",
                      "GUI/Fonts/AveriaSerif-Bold.ttf", 
                      FONT_SIZE,
                      true);
    }
}

void onTick(CRules@ this) {
	if (getNet().isClient()) {
		if (getGameTime() % 60 == 0) {
			// Cache so it doesn't have to be calculated every tick
			this.set_u16("chicken count team0", GetChickenCountForTeam(0));
			this.set_u16("chicken count team1", GetChickenCountForTeam(1));
			this.set_u16("egg count team0", GetEggCountForTeam(0));
			this.set_u16("egg count team1", GetEggCountForTeam(1));
		}

		if (getGameTime() % 120 == 0) {
			UpdateChickenCountLabels();
		}
	}
}

void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }

	for (int teamNum=0; teamNum <= 1; ++teamNum) {
		Vec2f topLeft(12, 12 + 64 * teamNum);
		GUI::DrawRectangle(topLeft, topLeft + Vec2f(150, 50));
		GUI::SetFont("score font");

		u16 chickenCount = this.get_u16("chicken count team" + teamNum);
		u16 eggCount = this.get_u16("egg count team" + teamNum);

		SColor color = teamNum == 0 ? TEAM0COLOR : TEAM1COLOR;
		GUI::DrawText("Chickens: " + chickenCount, topLeft + Vec2f(4,4), color);
		GUI::DrawText("Eggs: " + eggCount, topLeft + Vec2f(4,20), color);
		//GUI::DrawIcon(gui_image_fname, frame , Vec2f(16, 24), topLeft + startFlags + Vec2f(14 + step * 32, 0) , 1.0f, hud.team_num);
	}

	// Draw bar graph of progress
	Vec2f graphUITopLeft(180, 12);
	//GUI::DrawTextCentered("Chick-o-meter", graphUITopLeft + Vec2f(31,0), color_white);
	for (int teamNum=0; teamNum <= 1; ++teamNum) {
		Vec2f topLeft = graphUITopLeft + Vec2f(32, 0) * teamNum;
		u16 chickenCount = this.get_u16("chicken count team" + teamNum);
		u16 chickensToWin = this.get_u16("chickens_to_win");
		SColor color = teamNum == 0 ? TEAM0COLOR : TEAM1COLOR;

		float pad = 2;
		Vec2f dim = Vec2f(30, 64 + 50);
		float chickenPct = Maths::Min(1.0, chickenCount / float(chickensToWin)); // limit to 1 or the bar goes weird

		GUI::DrawRectangle(topLeft, topLeft+dim);
		GUI::DrawRectangle(topLeft + Vec2f(pad,pad) + Vec2f(0, (dim.y-2*pad)*(1-chickenPct)),
				           topLeft + dim - Vec2f(pad, pad),
						   color);
	}

	// Info bit
	Vec2f infoUITopLeft(12, 12 + 64 + 50 + 14);
	GUI::SetFont("hud");
	GUI::DrawRectangle(infoUITopLeft, infoUITopLeft+Vec2f(168+32+30, 80));
	Vec2f ptr = infoUITopLeft + Vec2f(4,4);
	GUI::DrawText("INSTRUCTIONS:", ptr, color_white);
	ptr.y += 16;
	GUI::DrawText("- Hatch " + this.get_u16("chickens_to_win") + " chickens to win!", ptr, color_white);
	ptr.y += 16;
	GUI::DrawText("- Chickens won't hatch if", ptr, color_white);
	ptr.y += 16;
	GUI::DrawText("  more than " + CHICKEN_LIMIT_LOCAL + " are together.", ptr, color_white);

	RenderChickenCountLabels();

	string propname = "ctf spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			string spawn_message = "Respawn in: " + spawn;
			if (spawn >= 250)
			{
				spawn_message = "Respawn in: (approximately never)";
			}

			GUI::SetFont("hud");
			GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}

// Adds numbers on groups of chickens so it's easy to see how many there are
void UpdateChickenCountLabels() {
	log("UpdateChickenCountLabels", "Called");
	CBlob@[] chickens = GetChickens();
	CHICKEN_COUNT_LABELS.clear();

	for (int i=0; i < chickens.length; ++i) {
		chickens[i].set_bool("labelled", false);
	}

	for (int i=0; i < chickens.length; ++i) {
		CBlob@ c = chickens[i];
		if (c.get_bool("labelled") == false) {
			c.set_bool("labelled", true);
			log("UpdateChickenCountLabels", "Group at " + c.getPosition().x + "," + c.getPosition().y);

			int chickenCount = 0;
			CBlob@[] nearbyBlobs;
			getMap().getBlobsInRadius(c.getPosition(), CHICKEN_LIMIT_RADIUS, @nearbyBlobs);

			for (int j=0; j < nearbyBlobs.length; ++j) {
				CBlob@ blob = nearbyBlobs[j];
				if (blob.getName() == "chicken" && blob.getTeamNum() == c.getTeamNum()) {
					chickenCount++;
					blob.set_bool("labelled", true);
				}
			}

			ChickenCountLabel label;
			label.count = chickenCount;
			label.pos = c.getPosition();
			label.teamNum = c.getTeamNum();
			CHICKEN_COUNT_LABELS.push_back(label);
		}
	}
}


void RenderChickenCountLabels() {
	for (int i=0; i < CHICKEN_COUNT_LABELS.length; ++i) {
		ChickenCountLabel label = CHICKEN_COUNT_LABELS[i];
		Vec2f screenPos = getDriver().getScreenPosFromWorldPos(label.pos);
		GUI::SetFont("hud");
		SColor color; 
		if (label.teamNum == 0)
			color =	TEAM0COLOR;
		else if (label.teamNum == 1) 
			color = TEAM1COLOR;
		else
			color = color_white;
		GUI::DrawTextCentered("" + label.count, screenPos, color);
	}
}