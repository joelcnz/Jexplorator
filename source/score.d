import base;

struct Score {
	/+
	int _totalDiamonds;
	
	void totalDiamonds(int totalDiamonds0) { _totalDiamonds = totalDiamonds0; }
	int totalDiamonds() { return _totalDiamonds; }
	+/

	int getGuyDiamonds(PortalSide side) { return g_guys[side].dashBoard.diamonds; }

	int getGuyScore(PortalSide side) { return g_guys[side].dashBoard.score; }
	
	bool allDiamondsQ() {
		return getGuyDiamonds(PortalSide.left) + getGuyDiamonds(PortalSide.right) == g_guys[0].dashBoard.totalDiamonds;
	}

	bool targetDiamondsQ() {
		return getGuyDiamonds(PortalSide.left) + getGuyDiamonds(PortalSide.right) >= g_campaign._current._diamonds;
	}
	
	string winner() {
		immutable 
			left = getGuyScore(PortalSide.left),
			right = getGuyScore(PortalSide.right);

		if (left == right)
			return "It's a Draw!";
		else if (left > right)
			return "Left player Wins!";
		else
			return "Right player Wins!";
	}
}