import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class CardDeck {

	// List<URL_Freq> urlList;
	private List<UrlInfo> unusedCards;
	private List<UrlInfo> usedCards;
	private WorkloadMix wlm;

	public CardDeck(WorkloadMix wlm) {
		this.unusedCards = new ArrayList<UrlInfo>();
		this.usedCards = new ArrayList<UrlInfo>();
		this.wlm = wlm;

		// First get the minimal nuber of cards in a deck
		int minimalNumber = this.getMinimalNumberOfCards();
	
		// Now set the cards by adding required cards to the unusedCards deck
		for (URL_Freq f : wlm.getUrlList()) {
			for (int i = 0; i < (f.getFreq() * minimalNumber) / 100; i++) {
				this.unusedCards.add(f.getUrl());
			}
		}

	}

	public UrlInfo getNextCard() {

		if (this.unusedCards.size() > 0) {
			int max = this.unusedCards.size() - 1;
			Random rand = new Random();
			return this.unusedCards.get((int) (rand.nextDouble() * (max + 1)));
		} else {
			for (UrlInfo i : this.usedCards) {
				this.unusedCards.add(i);
			}
			this.usedCards.clear();
			Output.stream().println("TTT");
			return this.getNextCard();
		}
	}

	public void printUnusedCards() {
		for (UrlInfo c : this.unusedCards) {
			Output.stream().println(c);
		}
	}

	
	private int getMinimalNumberOfCards() {
		boolean downscale;
		int i;
		for (i = 1; i < 100; i++) {
			downscale = true;
			for (URL_Freq f : this.wlm.getUrlList()) {
				if ((i * f.getFreq()) % 100 != 0) {
					downscale = false;
					break;
				}
			}
			if (downscale)
				break;
		}
		return i;
	}

}
