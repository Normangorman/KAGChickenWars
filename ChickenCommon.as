const int LAY_EGG_CHANCE = 60 * getTicksASecond();
const int CHICKEN_SOUND_CHANCE = 15*getTicksASecond();
const int EGG_GROW_TIME = 50 * getTicksASecond();
const float CHICKEN_LIMIT_RADIUS = 2 * 8.0;
const int CHICKEN_LIMIT_LOCAL = 5; // max in radius to hatch
const int EGG_LIMIT_LOCAL = 10;
const int EGG_UPDATE_FREQ = 120;


shared CBlob@[] GetChickens() {
    CBlob@[] chickens;
    getBlobsByName("chicken", @chickens);
    return chickens;
}

shared CBlob@[] GetEggs() {
    CBlob@[] eggs;
    getBlobsByName("egg", @eggs);
    return eggs;
}

shared int GetChickenCountForTeam(int teamNum) {
    CBlob@[] chickens = GetChickens();
    int count = 0;

    for (int i=0; i < chickens.length; ++i) {
        if (chickens[i].getTeamNum() == teamNum)
            ++count;
    }

    return count;
}

shared int GetEggCountForTeam(int teamNum) {
    CBlob@[] eggs = GetEggs();
    int count = 0;

    for (int i=0; i < eggs.length; ++i) {
        if (eggs[i].getTeamNum() == teamNum)
            ++count;
    }

    return count;
}