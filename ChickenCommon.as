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